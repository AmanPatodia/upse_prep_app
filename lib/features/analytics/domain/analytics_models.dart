class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.dailyStudyMinutes,
    required this.streakDays,
    required this.weeklyProgressPercent,
    required this.pyqCoveragePercent,
    required this.mockScores,
    required this.subjectStrength,
    required this.revisionPending,
  });

  final int dailyStudyMinutes;
  final int streakDays;
  final double weeklyProgressPercent;
  final double pyqCoveragePercent;
  final List<double> mockScores;
  final Map<String, double> subjectStrength;
  final int revisionPending;
}
