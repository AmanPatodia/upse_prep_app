enum AiUpdateType {
  summary,
  noteConversion,
  generatedMcq,
  topicDetection,
  revisionQuestions,
  lastMinuteNotes,
}

class AiUpdate {
  const AiUpdate({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final AiUpdateType type;
  final String title;
  final String content;
  final DateTime createdAt;
}
