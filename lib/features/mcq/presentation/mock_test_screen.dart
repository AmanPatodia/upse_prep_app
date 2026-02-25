import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/common_widgets.dart';
import 'bloc/mcq_cubit.dart';

class MockTestScreen extends StatefulWidget {
  const MockTestScreen({super.key});

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<McqCubit>();
      if (cubit.state.attemptHistory.isEmpty) {
        cubit.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prelims Mock Tests')),
      body: BlocBuilder<McqCubit, McqState>(
        builder: (context, state) {
          if (state.isLoading && state.attemptHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.attemptHistory.isEmpty) {
            return Center(child: Text('Failed: ${state.error}'));
          }

          return ListView(
            children: [
              const SizedBox(height: 8),
              const SectionHeader(title: 'Attempt History & Analysis'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow_outlined),
                  onPressed: () {},
                  label: const Text('Start 100Q Timed Mock (120 mins)'),
                ),
              ),
              ...state.attemptHistory.map(
                (item) => MetricCard(
                  label:
                      'Attempt ${item.timestamp.toLocal().toString().split(' ').first}',
                  value: '${item.accuracyPercent.toStringAsFixed(1)}% accuracy',
                  subtitle:
                      'Speed: ${item.avgSecondsPerQuestion.toStringAsFixed(0)} sec/question • Score ${item.correct}/${item.total}',
                ),
              ),
              const MetricCard(
                label: 'Weak area analysis',
                value: 'Polity - Fundamental Rights',
                subtitle:
                    'Recommended: revise chapter, then solve 25 hard questions.',
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
