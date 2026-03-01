import 'dart:convert';

import 'package:flutter/services.dart';
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
  static const _bankKey = 'pyq_bank_v4';

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

    final imported = await _loadFromAsset();
    final seeded = [
      ..._seedQuestions(),
      ...imported,
    ];
    await _bankBox.put(
      _bankKey,
      seeded.map((e) => e.toMap()).toList(growable: false),
    );
    return seeded;
  }

  Future<List<PyqQuestion>> _loadFromAsset() async {
    try {
      final raw = await rootBundle.loadString('assets/data/pyqs.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <PyqQuestion>[];
      final items = <PyqQuestion>[];
      for (final row in decoded.whereType<Map>()) {
        final map = row.cast<String, dynamic>();
        final year = (map['year'] as num?)?.toInt() ?? 0;
        final subject = (map['subject']?.toString() ?? '').trim();
        final question = (map['question']?.toString() ?? '').trim();
        final options = (map['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
        if (year == 0 || question.isEmpty || options.length < 2) continue;

        final paperNumber = (map['paperNumber'] as num?)?.toInt() ?? 1;
        final paperTypeRaw = (map['paperType']?.toString() ?? 'gs').toLowerCase();
        final paperType =
            paperTypeRaw == 'csat' ? PyqPaperType.csat : PyqPaperType.gs;
        final qNo = (map['questionNumber'] as num?)?.toInt() ?? (items.length + 1);
        final id = 'pyq-$year-${paperType.name}-$paperNumber-q$qNo';
        final answerIndex = _parseAnswerToIndex(map['answer']);
        final explanation = (map['explanation']?.toString() ?? '').trim();

        items.add(
          PyqQuestion(
            id: id,
            year: year,
            paperType: paperType,
            subject: subject.isEmpty ? 'General Studies' : subject,
            chapter: (map['chapter']?.toString() ?? 'Paper $paperNumber').trim(),
            question: question,
            options: options,
            correctIndex:
                answerIndex >= 0 && answerIndex < options.length ? answerIndex : 0,
            explanation:
                explanation.isEmpty ? 'Answer key: Expert (Unofficial)' : explanation,
            topicTag: (map['topicTag']?.toString() ?? 'PYQ').trim(),
            difficulty: Difficulty.values.firstWhere(
              (d) => d.name == (map['difficulty']?.toString() ?? 'medium'),
              orElse: () => Difficulty.medium,
            ),
            isCurrentAffairsLinked:
                map['isCurrentAffairsLinked'] as bool? ?? false,
            sourceName: map['sourceName']?.toString() ?? 'Imported PYQ Dataset',
            sourceUrl: map['sourceUrl']?.toString() ?? _sourceUrl,
          ),
        );
      }
      return items;
    } catch (_) {
      return const <PyqQuestion>[];
    }
  }

  int _parseAnswerToIndex(Object? answer) {
    if (answer is int) return answer;
    final raw = (answer?.toString() ?? '').trim().toUpperCase();
    if (raw.isEmpty) return 0;
    final cleaned = raw.replaceAll(RegExp(r'[^A-E0-9-]'), '');
    if (cleaned.isEmpty) return 0;
    const letters = ['A', 'B', 'C', 'D', 'E'];
    if (letters.contains(cleaned)) return letters.indexOf(cleaned);
    final asNum = int.tryParse(cleaned);
    if (asNum == null) return 0;
    return asNum > 0 ? asNum - 1 : asNum;
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
      final key = _groupKeyFromQuestion(q);
      grouped.putIfAbsent(key, () => []).add(q);
    }

    final sortedKeys = grouped.keys.toList(growable: false)..sort((a, b) {
      final ay = _yearFromGroupKey(a);
      final by = _yearFromGroupKey(b);
      if (ay != by) return by.compareTo(ay);
      return a.compareTo(b);
    });

    return sortedKeys
        .asMap()
        .entries
        .map((entry) {
          final idx = entry.key + 1;
          final key = entry.value;
          final year = _yearFromGroupKey(key);
          final paperType = _paperTypeFromGroupKey(key);
          final paperNumber = _paperNumberFromGroupKey(key);
          final questions = grouped[key]!;
          final label = paperType == PyqPaperType.gs ? 'GS Paper I' : 'CSAT Paper II';
          final title = paperNumber > 1
              ? 'PYQ $paperNumber: $year $label'
              : 'PYQ $idx: $year $label';
          return PyqTestCatalogItem(
            testId: 'pyq-$year-${paperType.name}-$paperNumber',
            title: title,
            year: year,
            paperType: paperType,
            questionCount: questions.length,
            durationSeconds: 120 * 60,
            sourceName: questions.first.sourceName ?? 'PYQ Source',
            sourceUrl: questions.first.sourceUrl ?? _sourceUrl,
            isOfficialAnswerKey: questions.any(
              (q) => q.explanation.toLowerCase().contains('official'),
            ),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<PyqTestPaper> getTestById(String testId) async {
    final match = RegExp(r'pyq-(\d{4})-(gs|csat)(?:-(\d+))?').firstMatch(testId);
    if (match == null) {
      throw Exception('Invalid test id: $testId');
    }

    final year = int.parse(match.group(1)!);
    final paperType =
        match.group(2) == 'gs' ? PyqPaperType.gs : PyqPaperType.csat;
    final paperNumber = int.tryParse(match.group(3) ?? '') ?? 1;

    final all = await _getBank();
    final selected = all
        .where((q) => _groupKeyFromQuestion(q) == '$year-${paperType.name}-$paperNumber')
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
      title: paperNumber > 1 ? 'PYQ $paperNumber: $year $label' : '$year $label',
      durationSeconds: 120 * 60,
      questions: selected,
    );
  }

  String _groupKeyFromQuestion(PyqQuestion q) {
    final match = RegExp(r'^pyq-(\d{4})-(gs|csat)-(\d+)-q\d+$').firstMatch(q.id);
    if (match != null) {
      return '${match.group(1)}-${match.group(2)}-${match.group(3)}';
    }
    return '${q.year}-${q.paperType.name}-1';
  }

  int _yearFromGroupKey(String key) => int.parse(key.split('-')[0]);

  PyqPaperType _paperTypeFromGroupKey(String key) =>
      key.split('-')[1] == 'csat' ? PyqPaperType.csat : PyqPaperType.gs;

  int _paperNumberFromGroupKey(String key) =>
      int.tryParse(key.split('-')[2]) ?? 1;

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
