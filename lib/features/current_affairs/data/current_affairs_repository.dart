import '../domain/current_affairs_models.dart';

abstract class CurrentAffairsRepository {
  Future<List<CurrentAffairItem>> getDailyItems();
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
      ),
    ];
  }
}
