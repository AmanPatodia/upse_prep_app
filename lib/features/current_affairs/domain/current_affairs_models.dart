class CurrentAffairItem {
  const CurrentAffairItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.date,
    required this.tags,
    required this.facts,
    this.isBookmarked = false,
    this.reviseLater = false,
  });

  final String id;
  final String title;
  final String summary;
  final DateTime date;
  final List<String> tags;
  final List<String> facts;
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
      isBookmarked: isBookmarked ?? this.isBookmarked,
      reviseLater: reviseLater ?? this.reviseLater,
    );
  }
}
