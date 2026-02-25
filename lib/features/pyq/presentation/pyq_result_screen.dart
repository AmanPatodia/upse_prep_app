import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import 'bloc/pyq_home_cubit.dart';
import 'bloc/pyq_test_cubit.dart';

class PyqResultScreen extends StatelessWidget {
  const PyqResultScreen({super.key});

  String _option(int index) => String.fromCharCode(65 + index);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PyqTestCubit>().state;
    final report = state.report;

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PYQ Result')),
        body: const SafeArea(
          child: Center(child: Text('No completed report found.')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PYQ Test Analysis')),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 8),
            MetricCard(
              label: 'Score Summary',
              value: '${report.correct}/${report.total}',
              subtitle:
                  'Accuracy ${report.accuracyPercent.toStringAsFixed(1)}%',
            ),
            MetricCard(
              label: 'Correct',
              value: '${report.correct}',
              subtitle: 'Questions answered correctly',
            ),
            MetricCard(
              label: 'Wrong',
              value: '${report.wrong}',
              subtitle: 'Questions answered incorrectly',
            ),
            MetricCard(
              label: 'Unattempted',
              value: '${report.unattempted}',
              subtitle: 'Questions skipped',
            ),
            MetricCard(
              label: 'Time Taken',
              value:
                  '${(report.timeTakenSeconds / 60).toStringAsFixed(1)} mins',
              subtitle:
                  'Out of ${(report.durationSeconds / 60).toStringAsFixed(0)} mins',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Full Paper Review',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            ...report.reviews.asMap().entries.map((entry) {
              final index = entry.key;
              final review = entry.value;
              final statusText =
                  review.isUnattempted
                      ? 'Unattempted'
                      : (review.isCorrect ? 'Correct' : 'Wrong');
              final statusColor =
                  review.isUnattempted
                      ? Colors.grey
                      : (review.isCorrect
                          ? Colors.green
                          : Theme.of(context).colorScheme.error);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Q${index + 1}. ${review.question}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Chip(
                            label: Text(statusText),
                            backgroundColor: statusColor.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...review.options.asMap().entries.map(
                        (opt) => Text('${_option(opt.key)}. ${opt.value}'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your answer: ${review.selectedIndex == null ? 'Not attempted' : _option(review.selectedIndex!)}',
                      ),
                      Text('Correct answer: ${_option(review.correctIndex)}'),
                      const SizedBox(height: 6),
                      Text('Explanation: ${review.explanation}'),
                    ],
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () async {
                  context.read<PyqTestCubit>().reset();
                  await context.read<PyqHomeCubit>().load();
                  if (context.mounted) context.go('/pyq');
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to PYQ Home'),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
