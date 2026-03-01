import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/logging/app_logger.dart';
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
  static const _logTag = 'PyqRepo';
  static const _indexAssetPath = 'assets/data/pyq/index.json';
  static const _defaultSourceUrl =
      'https://www.upsc.gov.in/examinations/previous-question-papers';

  final Map<String, List<PyqQuestion>> _paperCache = {};
  List<_PyqPaperManifest>? _manifestCache;

  Box get _attemptBox => Hive.box(AppConstants.pyqAttemptsBox);

  Future<List<_PyqPaperManifest>> _getManifest() async {
    if (_manifestCache != null) return _manifestCache!;

    try {
      AppLogger.debug(_logTag, 'Loading manifest: $_indexAssetPath');
      final raw = await rootBundle.loadString(_indexAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        AppLogger.warn(_logTag, 'Manifest is not a list. Returning empty.');
        _manifestCache = const <_PyqPaperManifest>[];
        return _manifestCache!;
      }

      final manifests = decoded
          .whereType<Map>()
          .map((e) => _PyqPaperManifest.fromMap(e.cast<String, dynamic>()))
          .where((e) => e.assetPath.trim().isNotEmpty)
          .toList(growable: false)
        ..sort((a, b) {
          if (a.year != b.year) return b.year.compareTo(a.year);
          if (a.paperType != b.paperType) {
            return a.paperType == PyqPaperType.gs ? -1 : 1;
          }
          return a.paperNumber.compareTo(b.paperNumber);
        });

      _manifestCache = manifests;
      AppLogger.info(_logTag, 'Manifest loaded. papers=${manifests.length}');
      return manifests;
    } catch (error, stackTrace) {
      AppLogger.error(
        _logTag,
        'Failed to load manifest: $_indexAssetPath',
        error: error,
        stackTrace: stackTrace,
      );
      _manifestCache = const <_PyqPaperManifest>[];
      return _manifestCache!;
    }
  }

  Future<List<PyqQuestion>> _loadPaperQuestions(_PyqPaperManifest manifest) async {
    final cached = _paperCache[manifest.testId];
    if (cached != null) return cached;

    try {
      AppLogger.debug(
        _logTag,
        'Loading paper file: ${manifest.assetPath} (testId=${manifest.testId})',
      );
      final raw = await rootBundle.loadString(manifest.assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        AppLogger.warn(
          _logTag,
          'Paper file is not a list: ${manifest.assetPath}',
        );
        _paperCache[manifest.testId] = const <PyqQuestion>[];
        return _paperCache[manifest.testId]!;
      }

      final items = <PyqQuestion>[];
      for (final row in decoded.whereType<Map>()) {
        final map = row.cast<String, dynamic>();
        final year = (map['year'] as num?)?.toInt() ?? manifest.year;
        final paperTypeRaw = (map['paperType']?.toString() ?? manifest.paperType.name)
            .trim()
            .toLowerCase();
        final paperType =
            paperTypeRaw == 'csat' ? PyqPaperType.csat : PyqPaperType.gs;
        final paperNumber =
            (map['paperNumber'] as num?)?.toInt() ?? manifest.paperNumber;
        final qNo = (map['questionNumber'] as num?)?.toInt() ?? (items.length + 1);

        final question = (map['question']?.toString() ?? '').trim();
        final options = (map['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
        if (question.isEmpty || options.length < 2) continue;

        final answerIndex = _parseAnswerToIndex(map['answer']);
        final explanation = (map['explanation']?.toString() ?? '').trim();

        items.add(
          PyqQuestion(
            id: 'pyq-$year-${paperType.name}-$paperNumber-q$qNo',
            year: year,
            paperType: paperType,
            subject: (map['subject']?.toString() ?? 'General Studies').trim(),
            chapter: (map['chapter']?.toString() ?? manifest.title).trim(),
            question: question,
            options: options,
            correctIndex:
                answerIndex >= 0 && answerIndex < options.length ? answerIndex : 0,
            explanation: explanation.isEmpty
                ? 'Answer key: Expert (Unofficial)'
                : explanation,
            topicTag: (map['topicTag']?.toString() ?? 'PYQ').trim(),
            difficulty: Difficulty.values.firstWhere(
              (d) => d.name == (map['difficulty']?.toString() ?? 'medium'),
              orElse: () => Difficulty.medium,
            ),
            isCurrentAffairsLinked: map['isCurrentAffairsLinked'] as bool? ?? false,
            sourceName: map['sourceName']?.toString() ?? manifest.sourceName,
            sourceUrl: map['sourceUrl']?.toString() ?? manifest.sourceUrl,
          ),
        );
      }

      items.sort((a, b) => _extractQuestionNumber(a.id).compareTo(_extractQuestionNumber(b.id)));
      _paperCache[manifest.testId] = items;
      AppLogger.info(
        _logTag,
        'Paper loaded: ${manifest.testId} questions=${items.length}',
      );
      return items;
    } catch (error, stackTrace) {
      AppLogger.error(
        _logTag,
        'Failed to load paper file: ${manifest.assetPath}',
        error: error,
        stackTrace: stackTrace,
      );
      _paperCache[manifest.testId] = const <PyqQuestion>[];
      return _paperCache[manifest.testId]!;
    }
  }

  int _extractQuestionNumber(String id) {
    final match = RegExp(r'-q(\d+)$').firstMatch(id);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
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

  @override
  Future<List<PyqQuestion>> getPyqs({
    int? year,
    String? subject,
    String? chapter,
  }) async {
    final manifests = await _getManifest();
    final all = <PyqQuestion>[];

    for (final manifest in manifests) {
      all.addAll(await _loadPaperQuestions(manifest));
    }

    return all
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
    final manifests = await _getManifest();
    AppLogger.info(_logTag, 'Building test catalog from manifests=${manifests.length}');
    return manifests
        .map(
          (m) => PyqTestCatalogItem(
            testId: m.testId,
            title: m.title,
            year: m.year,
            paperType: m.paperType,
            questionCount: m.questionCount,
            durationSeconds: m.durationSeconds,
            sourceName: m.sourceName,
            sourceUrl: m.sourceUrl,
            isOfficialAnswerKey: m.isOfficialAnswerKey,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<PyqTestPaper> getTestById(String testId) async {
    final manifests = await _getManifest();
    final manifest = manifests.where((m) => m.testId == testId).firstOrNull;
    if (manifest == null) {
      throw Exception('Invalid test id: $testId');
    }

    final questions = await _loadPaperQuestions(manifest);
    if (questions.isEmpty) {
      throw Exception('No PYQ data found for ${manifest.title}');
    }

    return PyqTestPaper(
      id: manifest.testId,
      title: manifest.title,
      durationSeconds: manifest.durationSeconds,
      questions: questions,
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

class _PyqPaperManifest {
  const _PyqPaperManifest({
    required this.testId,
    required this.title,
    required this.year,
    required this.paperType,
    required this.paperNumber,
    required this.questionCount,
    required this.durationSeconds,
    required this.sourceName,
    required this.sourceUrl,
    required this.isOfficialAnswerKey,
    required this.assetPath,
  });

  final String testId;
  final String title;
  final int year;
  final PyqPaperType paperType;
  final int paperNumber;
  final int questionCount;
  final int durationSeconds;
  final String sourceName;
  final String sourceUrl;
  final bool isOfficialAnswerKey;
  final String assetPath;

  factory _PyqPaperManifest.fromMap(Map<String, dynamic> map) {
    final year = (map['year'] as num?)?.toInt() ?? 0;
    final paperTypeRaw = (map['paperType']?.toString() ?? 'gs').trim().toLowerCase();
    final paperType = paperTypeRaw == 'csat' ? PyqPaperType.csat : PyqPaperType.gs;
    final paperNumber = (map['paperNumber'] as num?)?.toInt() ?? 1;
    final label = paperType == PyqPaperType.gs ? 'GS Paper I' : 'CSAT Paper II';

    return _PyqPaperManifest(
      testId: (map['testId']?.toString() ?? 'pyq-$year-${paperType.name}-$paperNumber').trim(),
      title: (map['title']?.toString() ?? 'PYQ $paperNumber: $year $label').trim(),
      year: year,
      paperType: paperType,
      paperNumber: paperNumber,
      questionCount: (map['questionCount'] as num?)?.toInt() ?? 0,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 120 * 60,
      sourceName: (map['sourceName']?.toString() ?? 'UPSC Previous Papers').trim(),
      sourceUrl: (map['sourceUrl']?.toString() ?? DemoPyqRepository._defaultSourceUrl).trim(),
      isOfficialAnswerKey: map['isOfficialAnswerKey'] as bool? ?? false,
      assetPath: (map['assetPath']?.toString() ?? '').trim(),
    );
  }
}
