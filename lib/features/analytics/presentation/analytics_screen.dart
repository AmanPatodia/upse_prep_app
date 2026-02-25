import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/common_widgets.dart';
import 'bloc/analytics_cubit.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsCubit>().state;

    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const SectionHeader(title: 'Dashboard & Analytics'),
          MetricCard(
            label: 'Daily study time',
            value: '${analytics.dailyStudyMinutes} mins',
            subtitle: 'Today',
          ),
          MetricCard(
            label: 'Streak',
            value: '${analytics.streakDays} days',
            subtitle: 'Consistency score improving',
          ),
          MetricCard(
            label: 'PYQ coverage',
            value: '${analytics.pyqCoveragePercent.toStringAsFixed(1)}%',
            subtitle: 'Target: 85% before prelims',
          ),
          MetricCard(
            label: 'Revision pending',
            value: '${analytics.revisionPending} topics',
            subtitle: 'High priority items: 5',
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mock test performance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: analytics.mockScores
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(growable: false),
                            isCurved: true,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...analytics.subjectStrength.entries.map(
            (entry) => MetricCard(
              label: '${entry.key} strength',
              value: '${entry.value.toStringAsFixed(1)}%',
              subtitle: 'Based on MCQs + PYQs + mocks',
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
