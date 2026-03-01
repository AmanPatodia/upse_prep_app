import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../../core/logging/app_logger.dart';
import '../domain/news_models.dart';

abstract class NewsRepository {
  Future<List<NewsItem>> getDailyNews();
}

class RssNewsRepository implements NewsRepository {
  RssNewsRepository({required Dio dio, this.perFeedItemLimit = 25}) : _dio = dio;

  final Dio _dio;
  final int perFeedItemLimit;

  static const _feedUrls = <String>[
    'https://www.hindustantimes.com/feeds/rss/india-news/rssfeed.xml',
    'https://timesofindia.indiatimes.com/rssfeeds/-2128936835.cms',
    'https://indianexpress.com/section/india/feed/',
  ];

  static const _examKeywords = <String>[
    'india',
    'government',
    'policy',
    'bill',
    'act',
    'economy',
    'inflation',
    'budget',
    'supreme court',
    'parliament',
    'environment',
    'climate',
    'science',
    'technology',
    'international',
    'security',
    'governance',
  ];

  @override
  Future<List<NewsItem>> getDailyNews() async {
    AppLogger.info('NewsRepo', 'Loading daily newspaper feeds');
    final itemsById = <String, NewsItem>{};

    for (final feedUrl in _feedUrls) {
      try {
        final parsed = await _fetchFeedDirect(feedUrl);
        for (final item in parsed) {
          if (_isExamRelevant('${item.title} ${item.summary}')) {
            itemsById[item.id] = item;
          }
        }
        AppLogger.debug(
          'NewsRepo',
          'Feed parsed: $feedUrl -> ${parsed.length} items',
        );
      } catch (e, st) {
        AppLogger.error(
          'NewsRepo',
          'Feed failed: $feedUrl',
          error: e,
          stackTrace: st,
        );
      }
    }

    final items = itemsById.values.toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));
    AppLogger.info('NewsRepo', 'Returning ${items.length} news items');
    return items;
  }

  Future<List<NewsItem>> _fetchFeedDirect(String feedUrl) async {
    final response = await _dio.get(
      feedUrl,
      options: Options(
        sendTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        responseType: ResponseType.plain,
        headers: const {'User-Agent': 'Mozilla/5.0 UPSCPrepApp/1.0'},
      ),
    );

    final xml = response.data?.toString() ?? '';
    if (xml.isEmpty) return const <NewsItem>[];

    final sourceName = _normalizeSourceName(feedUrl);
    final blocks = _extractItemBlocks(xml);
    final items = <NewsItem>[];

    for (final block in blocks.take(perFeedItemLimit)) {
      final title = _decodeHtml(_stripCdata(_extractTag(block, 'title') ?? '').trim());
      if (title.isEmpty) continue;
      final link = _decodeHtml(
        (_extractTag(block, 'link') ?? _extractAtomLink(block) ?? '').trim(),
      );
      final rawSummary = _extractTag(block, 'description') ??
          _extractTag(block, 'content:encoded') ??
          _extractTag(block, 'summary') ??
          '';
      final summary = _toPlainText(_decodeHtml(_stripCdata(rawSummary)));
      final rawDate = _extractTag(block, 'pubDate') ??
          _extractTag(block, 'published') ??
          _extractTag(block, 'updated') ??
          '';
      final date = DateTime.tryParse(rawDate) ??
          DateTime.tryParse(rawDate.replaceFirst(' GMT', 'Z')) ??
          DateTime.now();
      final id = _buildId(link: link, title: title);

      items.add(
        NewsItem(
          id: id,
          title: title,
          summary: summary.isEmpty ? '$sourceName daily news update' : summary,
          date: date,
          sourceName: sourceName,
          sourceUrl: link.isEmpty ? feedUrl : link,
        ),
      );
    }
    return items;
  }

  static String _normalizeSourceName(String feedUrl) {
    final lower = feedUrl.toLowerCase();
    if (lower.contains('hindustantimes.com')) return 'Hindustan Times';
    if (lower.contains('timesofindia.indiatimes.com')) return 'Times of India';
    if (lower.contains('indianexpress.com')) return 'The Indian Express';
    return 'Daily News';
  }

  static bool _isExamRelevant(String text) {
    final normalized = text.toLowerCase();
    return _examKeywords.any(normalized.contains);
  }

  static String _buildId({required String link, required String title}) {
    final raw = '$link|$title'.codeUnits;
    return sha1.convert(raw).toString().substring(0, 16);
  }

  static String _toPlainText(String html) {
    final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final normalizedSpace = withoutTags.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalizedSpace.length <= 320) return normalizedSpace;
    return normalizedSpace.substring(0, 320).trimRight();
  }

  static List<String> _extractItemBlocks(String xml) {
    final rssItems = RegExp(
      r'<item\b[^>]*>(.*?)</item>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(xml);
    if (rssItems.isNotEmpty) {
      return rssItems
          .map((m) => m.group(1) ?? '')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    final atomEntries = RegExp(
      r'<entry\b[^>]*>(.*?)</entry>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(xml);
    return atomEntries
        .map((m) => m.group(1) ?? '')
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  static String? _extractTag(String xml, String tag) {
    final escaped = RegExp.escape(tag);
    final match = RegExp(
      '<$escaped[^>]*>(.*?)</$escaped>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(xml);
    return match?.group(1);
  }

  static String? _extractAtomLink(String xml) {
    final hrefMatch = RegExp(
      r'<link[^>]*href="([^"]+)"[^>]*/?>',
      caseSensitive: false,
    ).firstMatch(xml);
    return hrefMatch?.group(1);
  }

  static String _stripCdata(String s) {
    return s.replaceAll('<![CDATA[', '').replaceAll(']]>', '');
  }

  static String _decodeHtml(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
