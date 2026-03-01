class CurrentAffairItem {
  const CurrentAffairItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.date,
    required this.tags,
    required this.facts,
    this.sourceName,
    this.sourceUrl,
    this.isBookmarked = false,
    this.reviseLater = false,
  });

  final String id;
  final String title;
  final String summary;
  final DateTime date;
  final List<String> tags;
  final List<String> facts;
  final String? sourceName;
  final String? sourceUrl;
  final bool isBookmarked;
  final bool reviseLater;

  CurrentAffairItem copyWith({bool? isBookmarked, bool? reviseLater}) {
    return CurrentAffairItem(
      id: id,
      title: title,
      summary: summary,
      date: date,
      tags: tags,
      facts: facts,
      sourceName: sourceName,
      sourceUrl: sourceUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      reviseLater: reviseLater ?? this.reviseLater,
    );
  }

  factory CurrentAffairItem.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final rawFacts = json['facts'];
    return CurrentAffairItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      tags:
          rawTags is List
              ? rawTags.map((e) => e.toString()).toList(growable: false)
              : const [],
      facts:
          rawFacts is List
              ? rawFacts.map((e) => e.toString()).toList(growable: false)
              : const [],
      sourceName: json['sourceName']?.toString(),
      sourceUrl: json['sourceUrl']?.toString(),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      reviseLater: json['reviseLater'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'date': date.toIso8601String(),
      'tags': tags,
      'facts': facts,
      'sourceName': sourceName,
      'sourceUrl': sourceUrl,
      'isBookmarked': isBookmarked,
      'reviseLater': reviseLater,
    };
  }
}
