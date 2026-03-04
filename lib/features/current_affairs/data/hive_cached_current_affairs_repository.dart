import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/current_affairs_models.dart';
import 'current_affairs_repository.dart';

class HiveCachedCurrentAffairsRepository implements CurrentAffairsRepository {
  static const _cacheKey = 'firestore_current_affairs_daily_v1';

  Box get _cacheBox => Hive.box(AppConstants.currentAffairsBox);

  @override
  Future<CurrentAffairsFetchResult> getDailyItems() async {
    final cached = _cacheBox.get(_cacheKey);
    if (cached is! List) {
      return const CurrentAffairsFetchResult(
        items: <CurrentAffairItem>[],
        source: CurrentAffairsDataSource.hiveCache,
      );
    }
    final items = cached
        .whereType<Map>()
        .map((e) => CurrentAffairItem.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    return CurrentAffairsFetchResult(
      items: items,
      source: CurrentAffairsDataSource.hiveCache,
    );
  }
}
