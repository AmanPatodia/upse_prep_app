enum Difficulty { easy, medium, hard }

class McqQuestion {
  const McqQuestion({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
  });

  final String id;
  final String subject;
  final String chapter;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final Difficulty difficulty;
}

class AttemptSummary {
  const AttemptSummary({
    required this.total,
    required this.correct,
    required this.avgSecondsPerQuestion,
    required this.timestamp,
  });

  final int total;
  final int correct;
  final double avgSecondsPerQuestion;
  final DateTime timestamp;

  double get accuracyPercent => total == 0 ? 0 : (correct / total) * 100;
}
