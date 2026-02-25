class BackgroundSyncService {
  Future<void> syncDailyCurrentAffairs() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Future<void> syncRevisionQueue() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> syncAiSuggestions() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }
}
