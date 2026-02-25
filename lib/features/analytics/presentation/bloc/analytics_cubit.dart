import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/analytics_models.dart';

class AnalyticsCubit extends Cubit<AnalyticsSnapshot> {
  AnalyticsCubit()
    : super(
        const AnalyticsSnapshot(
          dailyStudyMinutes: 185,
          streakDays: 22,
          weeklyProgressPercent: 74,
          pyqCoveragePercent: 61,
          mockScores: [62, 66, 71, 68, 74],
          subjectStrength: {
            'Polity': 78,
            'Economy': 64,
            'Environment': 59,
            'History': 72,
          },
          revisionPending: 14,
        ),
      );
}
