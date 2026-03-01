import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

import '../../../core/logging/app_logger.dart';
import '../domain/current_affairs_models.dart';

abstract class CurrentAffairsRepository {
  Future<List<CurrentAffairItem>> getDailyItems();
}

class ApiCurrentAffairsRepository implements CurrentAffairsRepository {
  ApiCurrentAffairsRepository({
    required Dio dio,
    required String baseUrl,
  }) : _dio = dio,
       _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  @override
  Future<List<CurrentAffairItem>> getDailyItems() async {
    final response = await _dio.get('$_baseUrl/current-affairs/daily');
    final data = response.data;
    if (data is! List) {
      throw StateError('Invalid current affairs payload');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(CurrentAffairItem.fromJson)
        .toList(growable: false);
  }
}

class OpenRssCurrentAffairsRepository implements CurrentAffairsRepository {
  OpenRssCurrentAffairsRepository({
    required Dio dio,
    this.perFeedItemLimit = 25,
  }) : _dio = dio;

  final Dio _dio;
  final int perFeedItemLimit;

  static const _rss2JsonBaseUrl = 'https://api.rss2json.com/v1/api.json';
  static const _feedUrls = <String>[
    // Insights IAS
    'https://www.insightsonindia.com/feed/',

    // Vision IAS
    'https://www.visionias.in/feed',
    'https://visionias.in/resources/current-affairs/feed',

    // PMF IAS
    'https://www.pmfias.com/feed/',

    // Vajiram and Ravi
    'https://vajiramandravi.com/feed/',

    // ClearIAS
    'https://www.clearias.com/feed/',

    // PIB (Govt)
    'https://pib.gov.in/RssMain.aspx?ModId=62',

    // Sanskriti IAS RSS candidate
    'https://www.sanskritiias.com/feed',
  ];
  static const _sanskritiListingUrl = 'https://www.sanskritiias.com/current-affairs';
  static const _upscKeywords = <String>[
    'upsc',
    'prelims',
    'mains',
    'cse',
    'gs paper',
    'mcq',
    'quiz',
    'governance',
    'polity',
    'economy',
    'environment',
    'science',
    'technology',
    'international relations',
    'security',
    'schemes',
    'parliament',
    'supreme court',
    'pib',
  ];

  @override
  Future<List<CurrentAffairItem>> getDailyItems() async {
    AppLogger.info('CurrentAffairsRepo', 'Starting UPSC feed fetch');
    final allItemsById = <String, CurrentAffairItem>{};
    final relevantItemsById = <String, CurrentAffairItem>{};

    for (final feedUrl in _feedUrls) {
      var directSuccess = false;
      try {
        AppLogger.debug('CurrentAffairsRepo', 'Fetching direct RSS: $feedUrl');
        final directItems = await _fetchFeedDirect(feedUrl);
        if (directItems.isNotEmpty) {
          directSuccess = true;
          for (final item in directItems) {
            final searchable = '${item.title} ${item.summary} ${item.tags.join(' ')}';
            allItemsById[item.id] = item;
            if (_isUpscRelevant(searchable)) {
              relevantItemsById[item.id] = item;
            }
          }
          AppLogger.debug(
            'CurrentAffairsRepo',
            'Direct RSS success: $feedUrl -> ${directItems.length} items',
          );
          continue;
        }
      } catch (_) {
        AppLogger.warn('CurrentAffairsRepo', 'Direct RSS failed: $feedUrl');
      }

      try {
        AppLogger.debug('CurrentAffairsRepo', 'Fallback rss2json feed: $feedUrl');
        final response = await _dio.get(
          _rss2JsonBaseUrl,
          queryParameters: {
            'rss_url': feedUrl,
            'count': perFeedItemLimit,
          },
          options: Options(
            sendTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        if ((response.statusCode ?? 500) >= 400) {
          AppLogger.warn(
            'CurrentAffairsRepo',
            'rss2json returned ${response.statusCode} for $feedUrl',
          );
          continue;
        }
        final data = _asJsonMap(response.data);
        if (data is! Map<String, dynamic>) {
          AppLogger.warn(
            'CurrentAffairsRepo',
            'Invalid JSON shape for feed: $feedUrl',
          );
          continue;
        }
        final feedTitle = (data['feed'] is Map<String, dynamic>)
            ? ((data['feed'] as Map<String, dynamic>)['title']?.toString() ?? '')
            : '';
        final rows = data['items'];
        if (rows is! List) {
          AppLogger.warn(
            'CurrentAffairsRepo',
            'No items list found for feed: $feedUrl',
          );
          continue;
        }
        AppLogger.debug(
          'CurrentAffairsRepo',
          'Feed parsed: ${feedTitle.isEmpty ? feedUrl : feedTitle}, rows=${rows.length}',
        );

        for (final row in rows.whereType<Map<String, dynamic>>()) {
          final title = (row['title']?.toString() ?? '').trim();
          if (title.isEmpty) continue;

          final link = (row['link']?.toString() ?? '').trim();
          final rawSummary =
              row['description']?.toString() ??
              row['content']?.toString() ??
              row['contentSnippet']?.toString() ??
              '';
          final summary = _toPlainText(rawSummary);
          final date =
              DateTime.tryParse(row['pubDate']?.toString() ?? '') ??
              DateTime.now();
          final categories = row['categories'];
          final categoryTags = categories is List
              ? categories
                    .map((e) => e.toString().trim())
                    .where((e) => e.isNotEmpty)
                    .toList(growable: false)
              : const <String>[];
          final inferredTags = _inferTags(
            title: title,
            summary: summary,
            categories: categoryTags,
          );

          final searchable = '$title $summary ${categoryTags.join(' ')}';
          final factSeed = summary.isEmpty ? title : summary;
          final facts = _topFacts(factSeed);
          final id = _buildId(link: link, title: title);
          final cleanedSummary = summary.isEmpty
              ? 'Open source: ${feedTitle.isEmpty ? 'UPSC current affairs' : feedTitle}'
              : summary;
          final item = CurrentAffairItem(
            id: id,
            title: title,
            summary: cleanedSummary,
            date: date,
            tags: inferredTags,
            facts: facts,
            sourceName: feedTitle.isEmpty ? 'UPSC RSS' : feedTitle,
            sourceUrl: link,
          );
          allItemsById[id] = item;
          if (_isUpscRelevant(searchable)) {
            relevantItemsById[id] = item;
          }
        }
      } catch (_) {
        AppLogger.warn(
          'CurrentAffairsRepo',
          'rss2json fallback failed: $feedUrl, directSuccess=$directSuccess',
        );
      }
    }
    AppLogger.info(
      'CurrentAffairsRepo',
      'After RSS fetch: all=${allItemsById.length}, relevant=${relevantItemsById.length}',
    );

    // Direct page scrape fallbacks for non-standard/no-RSS sources.
    final scrapedSanskriti = await _scrapeGenericListing(
      listingUrl: _sanskritiListingUrl,
      sourceName: 'Sanskriti IAS',
      hrefContains: '/current-affairs/',
      maxLinks: 30,
    );
    for (final item in scrapedSanskriti) {
      allItemsById[item.id] = item;
      final searchable = '${item.title} ${item.summary} ${item.tags.join(' ')}';
      if (_isUpscRelevant(searchable)) {
        relevantItemsById[item.id] = item;
      }
    }
    AppLogger.info(
      'CurrentAffairsRepo',
      'Sanskriti scrape fallback items: ${scrapedSanskriti.length}',
    );

    final merged = allItemsById.values.toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));
    if (merged.isNotEmpty) {
      AppLogger.info(
        'CurrentAffairsRepo',
        'Returning merged items: total=${merged.length}, relevant=${relevantItemsById.length}',
      );
      return merged;
    }

    // If strict filtering yields nothing due to feed format changes,
    // callers can still fall back to demo content.
    AppLogger.warn('CurrentAffairsRepo', 'No items from RSS or scrape');
    return const <CurrentAffairItem>[];
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

  static List<String> _inferTags({
    required String title,
    required String summary,
    required List<String> categories,
  }) {
    final haystack = '$title $summary ${categories.join(' ')}'.toLowerCase();
    final tags = <String>{};
    void addIfMatch(String keyword, String tag) {
      if (haystack.contains(keyword)) tags.add(tag);
    }

    addIfMatch('polity', 'Polity');
    addIfMatch('constitution', 'Polity');
    addIfMatch('economy', 'Economy');
    addIfMatch('budget', 'Economy');
    addIfMatch('inflation', 'Economy');
    addIfMatch('environment', 'Environment');
    addIfMatch('climate', 'Environment');
    addIfMatch('ecology', 'Environment');
    addIfMatch('science', 'Science & Tech');
    addIfMatch('technology', 'Science & Tech');
    addIfMatch('international', 'IR');
    addIfMatch('foreign', 'IR');
    addIfMatch('defence', 'Security');
    addIfMatch('internal security', 'Security');
    addIfMatch('governance', 'Governance');
    addIfMatch('ethics', 'Ethics');
    addIfMatch('social justice', 'Social Justice');

    if (tags.isEmpty) {
      tags.addAll(
        categories
            .where((e) => e.length > 2)
            .take(2)
            .map((e) => e.length > 24 ? e.substring(0, 24) : e),
      );
    }
    if (tags.isEmpty) tags.add('Current Affairs');
    return tags.take(3).toList(growable: false);
  }

  static List<String> _topFacts(String text) {
    final pieces = text
        .replaceAll(';', '.')
        .split('.')
        .map((e) => e.trim())
        .where((e) => e.length > 12)
        .take(3)
        .toList(growable: false);
    if (pieces.isNotEmpty) return pieces;
    return const ['Read full article for details'];
  }

  static bool _isUpscRelevant(String text) {
    final normalized = text.toLowerCase();
    return _upscKeywords.any(normalized.contains);
  }

  static Map<String, dynamic>? _asJsonMap(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String _decodeHtml(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  Future<List<CurrentAffairItem>> _fetchFeedDirect(String feedUrl) async {
    final response = await _dio.get(
      feedUrl,
      options: Options(
        sendTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        responseType: ResponseType.plain,
        headers: const {'User-Agent': 'Mozilla/5.0 UPSCPrepApp/1.0'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if ((response.statusCode ?? 500) >= 400) {
      throw StateError('Feed HTTP ${response.statusCode}');
    }
    final xml = response.data?.toString() ?? '';
    if (xml.isEmpty) return const <CurrentAffairItem>[];

    final feedTitle = _normalizeSourceName(
      feedUrl,
      _extractFeedTitle(xml) ?? 'UPSC RSS',
    );
    final blocks = _extractItemBlocks(xml);
    final items = <CurrentAffairItem>[];

    for (final block in blocks.take(perFeedItemLimit)) {
      final title = _decodeHtml(_stripCdata(_extractTag(block, 'title') ?? '').trim());
      if (title.isEmpty) continue;
      final link = _decodeHtml(
        (_extractTag(block, 'link') ?? _extractAtomLink(block) ?? '').trim(),
      );
      final rawSummary = _extractTag(block, 'description') ??
          _extractTag(block, 'content:encoded') ??
          _extractTag(block, 'summary') ??
          _extractTag(block, 'content') ??
          '';
      final summary = _toPlainText(_decodeHtml(_stripCdata(rawSummary)));
      final rawDate = _extractTag(block, 'pubDate') ??
          _extractTag(block, 'published') ??
          _extractTag(block, 'updated') ??
          '';
      final date = DateTime.tryParse(rawDate) ??
          DateTime.tryParse(rawDate.replaceFirst(' GMT', 'Z')) ??
          DateTime.now();
      final categoryMatches = RegExp(
        r'<category[^>]*>(.*?)</category>',
        caseSensitive: false,
        dotAll: true,
      ).allMatches(block);
      final categories = categoryMatches
          .map((m) => _decodeHtml(_stripCdata(m.group(1) ?? '').trim()))
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

      final inferredTags = _inferTags(
        title: title,
        summary: summary,
        categories: categories,
      );
      final id = _buildId(link: link, title: title);
      items.add(
        CurrentAffairItem(
          id: id,
          title: title,
          summary: summary.isEmpty ? 'Open source: $feedTitle' : summary,
          date: date,
          tags: inferredTags,
          facts: _topFacts(summary.isEmpty ? title : summary),
          sourceName: feedTitle,
          sourceUrl: link.isEmpty ? feedUrl : link,
        ),
      );
    }
    return items;
  }

  static String _normalizeSourceName(String feedUrl, String parsedTitle) {
    final lower = feedUrl.toLowerCase();
    if (lower.contains('insightsonindia.com')) return 'Insights IAS';
    if (lower.contains('pmfias.com')) return 'PMF IAS';
    if (lower.contains('visionias.in')) return 'Vision IAS';
    if (lower.contains('vajiramandravi.com')) return 'Vajiram & Ravi';
    if (lower.contains('pib.gov.in')) return 'PIB';
    if (lower.contains('clearias.com')) return 'ClearIAS';
    return parsedTitle;
  }

  static String? _extractFeedTitle(String xml) {
    final channelTitle = RegExp(
      r'<channel[^>]*>[\s\S]*?<title[^>]*>(.*?)</title>',
      caseSensitive: false,
    ).firstMatch(xml);
    if (channelTitle != null) {
      return _decodeHtml(_stripCdata(channelTitle.group(1) ?? '').trim());
    }
    final atomTitle = RegExp(
      r'<feed[^>]*>[\s\S]*?<title[^>]*>(.*?)</title>',
      caseSensitive: false,
    ).firstMatch(xml);
    if (atomTitle != null) {
      return _decodeHtml(_stripCdata(atomTitle.group(1) ?? '').trim());
    }
    return null;
  }

  static List<String> _extractItemBlocks(String xml) {
    final rssItems = RegExp(
      r'<item\b[^>]*>(.*?)</item>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(xml);
    if (rssItems.isNotEmpty) {
      return rssItems.map((m) => m.group(1) ?? '').where((e) => e.isNotEmpty).toList(growable: false);
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

  Future<List<CurrentAffairItem>> _scrapeGenericListing({
    required String listingUrl,
    required String sourceName,
    required String hrefContains,
    required int maxLinks,
  }) async {
    try {
      AppLogger.debug(
        'CurrentAffairsRepo',
        'Scraping listing: $listingUrl',
      );
      final response = await _dio.get(
        listingUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          responseType: ResponseType.plain,
          headers: const {'User-Agent': 'Mozilla/5.0 UPSCPrepApp/1.0'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if ((response.statusCode ?? 500) >= 400) {
        AppLogger.warn(
          'CurrentAffairsRepo',
          'Listing fetch failed with ${response.statusCode}: $listingUrl',
        );
        return const <CurrentAffairItem>[];
      }
      final html = response.data?.toString() ?? '';
      if (html.isEmpty) return const <CurrentAffairItem>[];

      final hrefRegex = RegExp(
        'href="([^"]*$hrefContains[^"]*)"',
        caseSensitive: false,
      );
      final links = <String>{};
      for (final match in hrefRegex.allMatches(html)) {
        final href = match.group(1);
        if (href == null || href.isEmpty) continue;
        final absolute = href.startsWith('http')
            ? href
            : _toAbsoluteUrl(listingUrl, href);
        links.add(absolute);
      }
      AppLogger.debug(
        'CurrentAffairsRepo',
        'Listing links found: source=$sourceName count=${links.length}',
      );

      final items = <CurrentAffairItem>[];
      for (final link in links.take(maxLinks)) {
        try {
          final detail = await _dio.get(
            link,
            options: Options(
              sendTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 12),
              responseType: ResponseType.plain,
              headers: const {'User-Agent': 'Mozilla/5.0 UPSCPrepApp/1.0'},
              validateStatus: (status) => status != null && status < 500,
            ),
          );
          if ((detail.statusCode ?? 500) >= 400) {
            AppLogger.warn(
              'CurrentAffairsRepo',
              'Detail fetch failed with ${detail.statusCode}: $link',
            );
            continue;
          }
          final detailHtml = detail.data?.toString() ?? '';
          if (detailHtml.isEmpty) continue;

          final title =
              _extractMetaContent(html: detailHtml, property: 'og:title') ??
              _extractMetaByName(detailHtml, 'title') ??
              _extractTitle(detailHtml) ??
              sourceName;
          final summary = _toPlainText(
            _extractMetaContent(html: detailHtml, property: 'og:description') ??
                _extractMetaByName(detailHtml, 'description') ??
                '',
          );
          final rawDate =
              _extractMetaContent(html: detailHtml, property: 'article:published_time') ??
              _extractMetaByName(detailHtml, 'publish-date') ??
              _extractMetaByName(detailHtml, 'date') ??
              '';
          final date = DateTime.tryParse(rawDate) ?? DateTime.now();
          final id = _buildId(link: link, title: title);

          items.add(
            CurrentAffairItem(
              id: id,
              title: _decodeHtml(title),
              summary: summary.isEmpty ? '$sourceName current affairs article' : _decodeHtml(summary),
              date: date,
              tags: const ['Current Affairs', 'UPSC'],
              facts: _topFacts(summary.isEmpty ? title : summary),
              sourceName: sourceName,
              sourceUrl: link,
            ),
          );
        } catch (_) {
          AppLogger.warn(
            'CurrentAffairsRepo',
            'Failed detail scrape: source=$sourceName link=$link',
          );
        }
      }
      return items;
    } catch (_) {
      AppLogger.warn(
        'CurrentAffairsRepo',
        'Listing scrape failed: source=$sourceName url=$listingUrl',
      );
      return const <CurrentAffairItem>[];
    }
  }

  static String _toAbsoluteUrl(String base, String href) {
    final baseUri = Uri.parse(base);
    return baseUri.resolve(href).toString();
  }

  static String? _extractMetaContent({
    required String html,
    required String property,
  }) {
    final regex = RegExp(
      'property="$property"\\s+content="([^"]+)"',
      caseSensitive: false,
    );
    return regex.firstMatch(html)?.group(1);
  }

  static String? _extractMetaByName(String html, String name) {
    final regex = RegExp(
      'name="$name"\\s+content="([^"]+)"',
      caseSensitive: false,
    );
    return regex.firstMatch(html)?.group(1);
  }

  static String? _extractTitle(String html) {
    final regex = RegExp(r'<title>(.*?)</title>', caseSensitive: false);
    return regex.firstMatch(html)?.group(1)?.trim();
  }
}

class DemoCurrentAffairsRepository implements CurrentAffairsRepository {
  @override
  Future<List<CurrentAffairItem>> getDailyItems() async {
    return [
      CurrentAffairItem(
        id: 'ca1',
        title: 'New RBI Liquidity Framework Update',
        summary:
            'RBI introduced calibrated liquidity operations with sectoral monitoring.',
        date: DateTime.now(),
        tags: const ['Economy', 'Banking'],
        facts: const [
          'Aims to stabilize short-term rates',
          'Impacts bond yields',
        ],
        sourceName: 'Demo Seed',
      ),
      CurrentAffairItem(
        id: 'ca2',
        title: 'COP Follow-up on Climate Finance',
        summary:
            'Developing countries seek transparent climate finance accounting mechanism.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        tags: const ['Environment', 'IR'],
        facts: const [
          'Focus on mitigation and adaptation',
          'Negotiation on loss and damage',
        ],
        sourceName: 'Demo Seed',
      ),
      CurrentAffairItem(
        id: 'ca3',
        title: 'Parliament Panel Flags Learning Outcome Gaps',
        summary:
            'Committee recommendations emphasize foundational literacy and stronger state-level monitoring.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        tags: const ['Governance', 'Education'],
        facts: const [
          'Targets grade-level learning indicators',
          'Stresses data-backed intervention blocks',
        ],
        sourceName: 'Demo Seed',
      ),
      CurrentAffairItem(
        id: 'ca4',
        title: 'India Expands Green Hydrogen Mission Support',
        summary:
            'Additional policy support focuses on domestic manufacturing and export competitiveness.',
        date: DateTime.now().subtract(const Duration(days: 3)),
        tags: const ['Environment', 'Economy'],
        facts: const [
          'Supports electrolyser ecosystem',
          'Links clean energy with industrial policy',
        ],
        sourceName: 'Demo Seed',
      ),
      CurrentAffairItem(
        id: 'ca5',
        title: 'Supreme Court Reiterates Due Process Safeguards',
        summary:
            'Recent observations reinforce procedural fairness and reasoned administrative decisions.',
        date: DateTime.now().subtract(const Duration(days: 4)),
        tags: const ['Polity', 'Governance'],
        facts: const [
          'Highlights constitutional morality',
          'Useful for polity and ethics answer writing',
        ],
        sourceName: 'Demo Seed',
      ),
      CurrentAffairItem(
        id: 'ca6',
        title: 'New Wetland Conservation Framework in Focus',
        summary:
            'States are asked to strengthen local inventories and integrate wetland plans with district development.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        tags: const ['Environment'],
        facts: const [
          'Importance for Ramsar and biodiversity questions',
          'Convergence model with local governance',
        ],
        sourceName: 'Demo Seed',
      ),
      CurrentAffairItem(
        id: 'ca7',
        title: 'Digital Public Infrastructure in Social Sector Delivery',
        summary:
            'Policy discussions assess interoperability, privacy standards and last-mile inclusion outcomes.',
        date: DateTime.now().subtract(const Duration(days: 6)),
        tags: const ['Science & Tech', 'Governance'],
        facts: const [
          'DPI model used in welfare delivery',
          'Data governance remains central concern',
        ],
        sourceName: 'Demo Seed',
      ),
      CurrentAffairItem(
        id: 'ca8',
        title: 'Indian Ocean Maritime Coordination Exercise',
        summary:
            'Regional navies conducted coordination drills focusing on maritime domain awareness and HADR response.',
        date: DateTime.now().subtract(const Duration(days: 7)),
        tags: const ['Security', 'IR'],
        facts: const [
          'Covers blue-water cooperation themes',
          'Relevant for maritime security notes',
        ],
        sourceName: 'Demo Seed',
      ),
    ];
  }
}

class FallbackCurrentAffairsRepository implements CurrentAffairsRepository {
  FallbackCurrentAffairsRepository({
    required CurrentAffairsRepository primary,
    required CurrentAffairsRepository fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final CurrentAffairsRepository _primary;
  final CurrentAffairsRepository _fallback;

  @override
  Future<List<CurrentAffairItem>> getDailyItems() async {
    try {
      final items = await _primary.getDailyItems();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Intentionally falls back to local seed data.
    }
    return _fallback.getDailyItems();
  }
}
