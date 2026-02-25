enum RevisionPriority { low, medium, high }

class Subject {
  const Subject({required this.id, required this.name, required this.chapters});

  final String id;
  final String name;
  final List<Chapter> chapters;
}

class Chapter {
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.topics,
  });

  final String id;
  final String subjectId;
  final String title;
  final List<Topic> topics;
}

class Topic {
  const Topic({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.notes,
    required this.importantPoints,
    required this.bookReferences,
    this.pdfUrl,
    this.imageUrls = const [],
    this.isBookmarked = false,
    this.isHighlighted = false,
    this.revisionPriority = RevisionPriority.medium,
  });

  final String id;
  final String chapterId;
  final String title;
  final String notes;
  final List<String> importantPoints;
  final List<String> bookReferences;
  final String? pdfUrl;
  final List<String> imageUrls;
  final bool isBookmarked;
  final bool isHighlighted;
  final RevisionPriority revisionPriority;
}
