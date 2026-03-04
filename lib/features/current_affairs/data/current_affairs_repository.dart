import '../domain/current_affairs_models.dart';

enum CurrentAffairsDataSource { firestore, hiveCache }

class CurrentAffairsFetchResult {
  const CurrentAffairsFetchResult({
    required this.items,
    required this.source,
  });

  final List<CurrentAffairItem> items;
  final CurrentAffairsDataSource source;
}

abstract class CurrentAffairsRepository {
  Future<CurrentAffairsFetchResult> getDailyItems();
}
