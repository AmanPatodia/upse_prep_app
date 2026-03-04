import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/current_affairs_models.dart';
import 'current_affairs_repository.dart';

class FirestoreCurrentAffairsRepository implements CurrentAffairsRepository {
  FirestoreCurrentAffairsRepository({
    required FirebaseFirestore firestore,
    this.collectionPath = 'current_affairs',
    this.limit = 300,
    this.cacheTtl = const Duration(hours: 6),
    this.maxFirestoreFetchesPerDay = 2,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final String collectionPath;
  final int limit;
  final Duration cacheTtl;
  final int maxFirestoreFetchesPerDay;

  static const _cacheKey = 'firestore_current_affairs_daily_v1';
  static const _cacheSyncedAtKey = 'firestore_current_affairs_synced_at_v1';
  static const _fetchDateKey = 'firestore_current_affairs_fetch_date_v1';
  static const _fetchCountKey = 'firestore_current_affairs_fetch_count_v1';
  static const _syncCursorKey = 'firestore_current_affairs_sync_cursor_v1';

  Box get _cacheBox => Hive.box(AppConstants.currentAffairsBox);

  @override
  Future<CurrentAffairsFetchResult> getDailyItems() async {
    final cachedItems = _readCachedItems();
    final cacheSyncedAt = _readCacheSyncedAt();
    final canFetchToday = _canFetchFromFirestoreToday();
    if (!canFetchToday && cachedItems.isNotEmpty) {
      AppLogger.info(
        'FirestoreCurrentAffairsRepo',
        'Daily Firestore fetch limit reached, returning cache (${cachedItems.length} items)',
      );
      return CurrentAffairsFetchResult(
        items: cachedItems,
        source: CurrentAffairsDataSource.hiveCache,
      );
    }

    final cacheFresh =
        cachedItems.isNotEmpty &&
        cacheSyncedAt != null &&
        DateTime.now().difference(cacheSyncedAt) <= cacheTtl;
    if (cacheFresh) {
      AppLogger.info(
        'FirestoreCurrentAffairsRepo',
        'Returning ${cachedItems.length} cached items (fresh cache hit)',
      );
      return CurrentAffairsFetchResult(
        items: cachedItems,
        source: CurrentAffairsDataSource.hiveCache,
      );
    }

    try {
      final syncCursor = _readSyncCursor();
      Query<Map<String, dynamic>> query;
      if (syncCursor != null) {
        query = _firestore
            .collection(collectionPath)
            .where('updatedAt', isGreaterThan: Timestamp.fromDate(syncCursor))
            .orderBy('updatedAt', descending: false)
            .limit(limit);
      } else {
        query = _firestore
            .collection(collectionPath)
            .orderBy('date', descending: true)
            .limit(limit);
      }
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await query.get();
      } catch (_) {
        // Fallback for documents missing/partially populated `updatedAt`.
        // This keeps the app resilient while data is being backfilled.
        snapshot = await _firestore
            .collection(collectionPath)
            .orderBy('date', descending: true)
            .limit(limit)
            .get();
      }

      final items = snapshot.docs
          .map((doc) {
            final map = doc.data();
            final dateValue = map['date'];
            final isoDate =
                dateValue is Timestamp
                    ? dateValue.toDate().toIso8601String()
                    : (dateValue?.toString() ??
                        DateTime.now().toIso8601String());
            final normalized = <String, dynamic>{
              ...map,
              'id':
                  (map['id']?.toString().trim().isNotEmpty ?? false)
                      ? map['id'].toString().trim()
                      : doc.id,
              'date': isoDate,
              // Support short-form authoring keys from Firestore.
              'summary': (map['summary']?.toString().trim().isNotEmpty ?? false)
                  ? map['summary']
                  : (map['inBrief']?.toString() ?? ''),
              'facts': (map['facts'] is List)
                  ? map['facts']
                  : (map['keyPoints'] is List ? map['keyPoints'] : const <dynamic>[]),
            };
            return CurrentAffairItem.fromJson(normalized);
          })
          .toList(growable: false);

      await _writeCache(items);
      await _writeSyncCursor(
        snapshot.docs
            .map((doc) => _extractCursorTimestamp(doc.data()))
            .whereType<DateTime>()
            .fold<DateTime?>(
              syncCursor,
              (latest, candidate) =>
                  latest == null || candidate.isAfter(latest) ? candidate : latest,
            ),
      );
      await _markFirestoreFetch();
      AppLogger.info(
        'FirestoreCurrentAffairsRepo',
        'Fetched ${items.length} delta items from Firestore',
      );
      return CurrentAffairsFetchResult(
        items: _readCachedItems(),
        source: CurrentAffairsDataSource.firestore,
      );
    } catch (error, stackTrace) {
      AppLogger.warn(
        'FirestoreCurrentAffairsRepo',
        'Firestore fetch failed, trying local cache',
      );
      if (cachedItems.isNotEmpty) {
        AppLogger.info(
          'FirestoreCurrentAffairsRepo',
          'Returning ${cachedItems.length} cached items',
        );
        return CurrentAffairsFetchResult(
          items: cachedItems,
          source: CurrentAffairsDataSource.hiveCache,
        );
      }
      AppLogger.error(
        'FirestoreCurrentAffairsRepo',
        'No cache available after Firestore failure',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  List<CurrentAffairItem> _readCachedItems() {
    final cached = _cacheBox.get(_cacheKey);
    if (cached is! List) return const <CurrentAffairItem>[];
    return cached
        .whereType<Map>()
        .map((e) => CurrentAffairItem.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  DateTime? _readCacheSyncedAt() {
    final raw = _cacheBox.get(_cacheSyncedAtKey)?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  DateTime? _readSyncCursor() {
    final raw = _cacheBox.get(_syncCursorKey)?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> _writeCache(List<CurrentAffairItem> items) async {
    final existing = _readCachedItems();
    final mergedById = <String, CurrentAffairItem>{
      for (final item in existing) item.id: item,
      for (final item in items) item.id: item,
    };
    final merged = mergedById.values.toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));

    await _cacheBox.put(
      _cacheKey,
      merged.map((e) => e.toJson()).toList(growable: false),
    );
    await _cacheBox.put(_cacheSyncedAtKey, DateTime.now().toIso8601String());
  }

  Future<void> _writeSyncCursor(DateTime? value) async {
    if (value == null) return;
    await _cacheBox.put(_syncCursorKey, value.toUtc().toIso8601String());
  }

  bool _canFetchFromFirestoreToday() {
    final todayKey = _dateKey(DateTime.now());
    final savedDate = _cacheBox.get(_fetchDateKey)?.toString() ?? '';
    if (savedDate != todayKey) return true;
    final count = (_cacheBox.get(_fetchCountKey) as int?) ?? 0;
    return count < maxFirestoreFetchesPerDay;
  }

  Future<void> _markFirestoreFetch() async {
    final todayKey = _dateKey(DateTime.now());
    final savedDate = _cacheBox.get(_fetchDateKey)?.toString() ?? '';
    if (savedDate != todayKey) {
      await _cacheBox.put(_fetchDateKey, todayKey);
      await _cacheBox.put(_fetchCountKey, 1);
      return;
    }
    final count = (_cacheBox.get(_fetchCountKey) as int?) ?? 0;
    await _cacheBox.put(_fetchCountKey, count + 1);
  }

  String _dateKey(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  DateTime? _extractCursorTimestamp(Map<String, dynamic> map) {
    final updatedAt = map['updatedAt'];
    if (updatedAt is Timestamp) return updatedAt.toDate().toUtc();
    final date = map['date'];
    if (date is Timestamp) return date.toDate().toUtc();
    final parsed = DateTime.tryParse(date?.toString() ?? '');
    return parsed?.toUtc();
  }
}
