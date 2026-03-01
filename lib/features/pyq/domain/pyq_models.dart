import '../../mcq/domain/mcq_models.dart';

enum PyqPaperType { gs, csat }

class PyqQuestion {
  const PyqQuestion({
    required this.id,
    required this.year,
    required this.paperType,
    required this.subject,
    required this.chapter,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.topicTag,
    required this.difficulty,
    required this.isCurrentAffairsLinked,
    this.sourceName,
    this.sourceUrl,
  });

  final String id;
  final int year;
  final PyqPaperType paperType;
  final String subject;
  final String chapter;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String topicTag;
  final Difficulty difficulty;
  final bool isCurrentAffairsLinked;
  final String? sourceName;
  final String? sourceUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'paperType': paperType.name,
      'subject': subject,
      'chapter': chapter,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'topicTag': topicTag,
      'difficulty': difficulty.name,
      'isCurrentAffairsLinked': isCurrentAffairsLinked,
      'sourceName': sourceName,
      'sourceUrl': sourceUrl,
    };
  }

  factory PyqQuestion.fromMap(Map<String, dynamic> map) {
    return PyqQuestion(
      id: map['id'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      paperType: PyqPaperType.values.firstWhere(
        (p) => p.name == (map['paperType'] as String? ?? 'gs'),
        orElse: () => PyqPaperType.gs,
      ),
      subject: map['subject'] as String? ?? '',
      chapter: map['chapter'] as String? ?? '',
      question: map['question'] as String? ?? '',
      options: (map['options'] as List<dynamic>? ?? []).cast<String>(),
      correctIndex: map['correctIndex'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
      topicTag: map['topicTag'] as String? ?? '',
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == (map['difficulty'] as String? ?? 'medium'),
        orElse: () => Difficulty.medium,
      ),
      isCurrentAffairsLinked: map['isCurrentAffairsLinked'] as bool? ?? false,
      sourceName: map['sourceName'] as String?,
      sourceUrl: map['sourceUrl'] as String?,
    );
  }
}

class PyqTestCatalogItem {
  const PyqTestCatalogItem({
    required this.testId,
    required this.title,
    required this.year,
    required this.paperType,
    required this.questionCount,
    required this.durationSeconds,
    required this.sourceName,
    required this.sourceUrl,
    this.isOfficialAnswerKey = false,
  });

  final String testId;
  final String title;
  final int year;
  final PyqPaperType paperType;
  final int questionCount;
  final int durationSeconds;
  final String sourceName;
  final String sourceUrl;
  final bool isOfficialAnswerKey;
}

class PyqQuestionReview {
  const PyqQuestionReview({
    required this.questionId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.selectedIndex,
  });

  final String questionId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int? selectedIndex;

  bool get isCorrect => selectedIndex != null && selectedIndex == correctIndex;
  bool get isUnattempted => selectedIndex == null;

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'selectedIndex': selectedIndex,
    };
  }

  factory PyqQuestionReview.fromMap(Map<String, dynamic> map) {
    return PyqQuestionReview(
      questionId: map['questionId'] as String? ?? '',
      question: map['question'] as String? ?? '',
      options: (map['options'] as List<dynamic>? ?? []).cast<String>(),
      correctIndex: map['correctIndex'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
      selectedIndex: map['selectedIndex'] as int?,
    );
  }
}

class PyqAttemptReport {
  const PyqAttemptReport({
    required this.testId,
    required this.submittedAt,
    required this.durationSeconds,
    required this.timeTakenSeconds,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.unattempted,
    required this.reviews,
  });

  final String testId;
  final DateTime submittedAt;
  final int durationSeconds;
  final int timeTakenSeconds;
  final int total;
  final int correct;
  final int wrong;
  final int unattempted;
  final List<PyqQuestionReview> reviews;

  double get accuracyPercent => total == 0 ? 0 : (correct / total) * 100;

  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'submittedAt': submittedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'timeTakenSeconds': timeTakenSeconds,
      'total': total,
      'correct': correct,
      'wrong': wrong,
      'unattempted': unattempted,
      'reviews': reviews.map((e) => e.toMap()).toList(growable: false),
    };
  }

  factory PyqAttemptReport.fromMap(Map<String, dynamic> map) {
    return PyqAttemptReport(
      testId: map['testId'] as String? ?? 'pyq-full-test',
      submittedAt:
          DateTime.tryParse(map['submittedAt'] as String? ?? '') ??
          DateTime.now(),
      durationSeconds: map['durationSeconds'] as int? ?? 7200,
      timeTakenSeconds: map['timeTakenSeconds'] as int? ?? 0,
      total: map['total'] as int? ?? 0,
      correct: map['correct'] as int? ?? 0,
      wrong: map['wrong'] as int? ?? 0,
      unattempted: map['unattempted'] as int? ?? 0,
      reviews: (map['reviews'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                PyqQuestionReview.fromMap((e as Map).cast<String, dynamic>()),
          )
          .toList(growable: false),
    );
  }
}

class PyqTestPaper {
  const PyqTestPaper({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.questions,
  });

  final String id;
  final String title;
  final int durationSeconds;
  final List<PyqQuestion> questions;
}
