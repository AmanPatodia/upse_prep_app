class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.date,
    required this.sourceName,
    required this.sourceUrl,
    this.isBookmarked = false,
  });

  final String id;
  final String title;
  final String summary;
  final DateTime date;
  final String sourceName;
  final String sourceUrl;
  final bool isBookmarked;

  NewsItem copyWith({bool? isBookmarked}) {
    return NewsItem(
      id: id,
      title: title,
      summary: summary,
      date: date,
      sourceName: sourceName,
      sourceUrl: sourceUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
