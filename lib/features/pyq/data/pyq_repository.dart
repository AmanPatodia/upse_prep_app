import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../mcq/domain/mcq_models.dart';
import '../domain/pyq_models.dart';

abstract class PyqRepository {
  Future<List<PyqQuestion>> getPyqs({
    int? year,
    String? subject,
    String? chapter,
  });
  Future<List<PyqTestCatalogItem>> getAvailableTests();
  Future<PyqTestPaper> getTestById(String testId);
  Future<PyqAttemptReport> evaluateAttempt({
    required PyqTestPaper testPaper,
    required Map<String, int> answers,
    required int timeTakenSeconds,
  });
  Future<void> saveAttempt(PyqAttemptReport report);
  Future<List<PyqAttemptReport>> getAttemptHistory();
}

class DemoPyqRepository implements PyqRepository {
  static const _bankKey = 'pyq_bank_v2';

  static const _subjects = {
    'History': ['Modern India', 'Art and Culture'],
    'Geography': ['Physical Geography', 'Indian Geography'],
    'Polity': ['Constitution', 'Parliament'],
    'Economy': ['National Income', 'Budget'],
    'Environment': ['Climate', 'Biodiversity'],
    'Science and Tech': ['Space', 'Biotechnology'],
    'CSAT Aptitude': ['Comprehension', 'Reasoning and Numeracy'],
  };

  static const _sourceUrl = 'https://vajiramandravi.com/upsc-previous-papers/';

  Box get _attemptBox => Hive.box(AppConstants.pyqAttemptsBox);
  Box get _bankBox => Hive.box(AppConstants.pyqBankBox);

  Future<List<PyqQuestion>> _getBank() async {
    final cached = _bankBox.get(_bankKey);
    if (cached is List) {
      return cached
          .whereType<Map>()
          .map((e) => PyqQuestion.fromMap(e.cast<String, dynamic>()))
          .toList(growable: false);
    }

    final seeded = _seedQuestions();
    await _bankBox.put(
      _bankKey,
      seeded.map((e) => e.toMap()).toList(growable: false),
    );
    return seeded;
  }

  List<PyqQuestion> _seedQuestions() {
    final questions = <PyqQuestion>[];

    for (final year in List<int>.generate(12, (i) => 2025 - i)) {
      for (final paperType in [PyqPaperType.gs, PyqPaperType.csat]) {
        for (var i = 0; i < 100; i++) {
          final subjectPool =
              paperType == PyqPaperType.gs
                  ? _subjects.keys.where((s) => s != 'CSAT Aptitude').toList()
                  : ['CSAT Aptitude'];

          final subject = subjectPool[i % subjectPool.length];
          final chapter = _subjects[subject]![i % _subjects[subject]!.length];

          questions.add(
            PyqQuestion(
              id: 'pyq-$year-${paperType.name}-${i + 1}',
              year: year,
              paperType: paperType,
              subject: subject,
              chapter: chapter,
              question:
                  'Consider the following statements regarding $chapter:\n'
                  '1. Statement A connected to UPSC prelims framework.\n'
                  '2. Statement B connected to UPSC prelims framework.\n'
                  'Which of the statements given above is/are correct?',
              options: const [
                '1 only',
                '2 only',
                'Both 1 and 2',
                'Neither 1 nor 2',
              ],
              correctIndex: i % 4,
              explanation:
                  'Reference style: UPSC PYQ pattern practice. This is indexed for $year ${paperType.name.toUpperCase()} paper under $chapter.',
              topicTag:
                  paperType == PyqPaperType.gs
                      ? 'Static Core'
                      : 'Aptitude Core',
              difficulty: Difficulty.values[i % Difficulty.values.length],
              isCurrentAffairsLinked:
                  paperType == PyqPaperType.gs && i % 5 == 0,
              sourceName: 'Vajiram & Ravi',
              sourceUrl: _sourceUrl,
            ),
          );
        }
      }
    }

    return questions;
  }

  @override
  Future<List<PyqQuestion>> getPyqs({
    int? year,
    String? subject,
    String? chapter,
  }) async {
    final items = await _getBank();
    return items
        .where((q) {
          final yearPass = year == null || q.year == year;
          final subjectPass = subject == null || q.subject == subject;
          final chapterPass = chapter == null || q.chapter == chapter;
          return yearPass && subjectPass && chapterPass;
        })
        .toList(growable: false);
  }

  @override
  Future<List<PyqTestCatalogItem>> getAvailableTests() async {
    final items = await _getBank();
    final grouped = <String, List<PyqQuestion>>{};

    for (final q in items) {
      final key = '${q.year}-${q.paperType.name}';
      grouped.putIfAbsent(key, () => []).add(q);
    }

    final sortedKeys = grouped.keys.toList(growable: false)..sort((a, b) {
      final ay = int.parse(a.split('-').first);
      final by = int.parse(b.split('-').first);
      if (ay != by) return by.compareTo(ay);
      return a.compareTo(b);
    });

    return sortedKeys
        .asMap()
        .entries
        .map((entry) {
          final idx = entry.key + 1;
          final key = entry.value;
          final parts = key.split('-');
          final year = int.parse(parts[0]);
          final paperType =
              parts[1] == 'gs' ? PyqPaperType.gs : PyqPaperType.csat;
          final questions = grouped[key]!;
          final label =
              paperType == PyqPaperType.gs ? 'GS Paper I' : 'CSAT Paper II';
          return PyqTestCatalogItem(
            testId: 'pyq-$year-${paperType.name}',
            title: 'PYQ $idx: $year $label',
            year: year,
            paperType: paperType,
            questionCount: questions.length,
            durationSeconds: 120 * 60,
            sourceName: 'Vajiram & Ravi',
            sourceUrl: _sourceUrl,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<PyqTestPaper> getTestById(String testId) async {
    final match = RegExp(r'pyq-(\d{4})-(gs|csat)').firstMatch(testId);
    if (match == null) {
      throw Exception('Invalid test id: $testId');
    }

    final year = int.parse(match.group(1)!);
    final paperType =
        match.group(2) == 'gs' ? PyqPaperType.gs : PyqPaperType.csat;

    final all = await _getBank();
    final selected = all
        .where((q) => q.year == year && q.paperType == paperType)
        .take(100)
        .toList(growable: false);

    if (selected.isEmpty) {
      throw Exception(
        'No PYQ data found for $year ${paperType.name.toUpperCase()}',
      );
    }

    final label = paperType == PyqPaperType.gs ? 'GS Paper I' : 'CSAT Paper II';

    return PyqTestPaper(
      id: testId,
      title: '$year $label',
      durationSeconds: 120 * 60,
      questions: selected,
    );
  }

  @override
  Future<PyqAttemptReport> evaluateAttempt({
    required PyqTestPaper testPaper,
    required Map<String, int> answers,
    required int timeTakenSeconds,
  }) async {
    var correct = 0;
    var wrong = 0;
    var unattempted = 0;

    final reviews = testPaper.questions
        .map((q) {
          final selected = answers[q.id];
          if (selected == null) {
            unattempted++;
          } else if (selected == q.correctIndex) {
            correct++;
          } else {
            wrong++;
          }

          return PyqQuestionReview(
            questionId: q.id,
            question: q.question,
            options: q.options,
            correctIndex: q.correctIndex,
            explanation: q.explanation,
            selectedIndex: selected,
          );
        })
        .toList(growable: false);

    return PyqAttemptReport(
      testId: testPaper.id,
      submittedAt: DateTime.now(),
      durationSeconds: testPaper.durationSeconds,
      timeTakenSeconds: timeTakenSeconds,
      total: testPaper.questions.length,
      correct: correct,
      wrong: wrong,
      unattempted: unattempted,
      reviews: reviews,
    );
  }

  @override
  Future<void> saveAttempt(PyqAttemptReport report) async {
    final key = '${report.testId}-${report.submittedAt.toIso8601String()}';
    await _attemptBox.put(key, report.toMap());
  }

  @override
  Future<List<PyqAttemptReport>> getAttemptHistory() async {
    final values = _attemptBox.values.toList(growable: false);
    final reports = values
        .whereType<Map>()
        .map((map) => PyqAttemptReport.fromMap(map.cast<String, dynamic>()))
        .toList(growable: false)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return reports;
  }
}
