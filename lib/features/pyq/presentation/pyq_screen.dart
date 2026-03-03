import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../domain/pyq_models.dart';
import 'bloc/pyq_home_cubit.dart';
import 'bloc/pyq_test_cubit.dart';

class PyqScreen extends StatefulWidget {
  const PyqScreen({super.key});

  @override
  State<PyqScreen> createState() => _PyqScreenState();
}

class _PyqScreenState extends State<PyqScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<PyqHomeCubit>();
      if (cubit.state.questions.isEmpty && !cubit.state.isLoading) {
        cubit.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PyqHomeCubit, PyqHomeState>(
      builder: (context, state) {
        if (state.isLoading && state.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.questions.isEmpty) {
          return Center(child: Text('Failed: ${state.error}'));
        }

        return SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const SectionHeader(title: 'PYQ Center'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Choose a year-wise paper like PYQ 1: 2025 GS/CSAT, attempt one question at a time with timer, then get full analysis + explanations.',
                ),
              ),
              const SizedBox(height: 8),
              const SectionHeader(title: 'GS Papers'),
              ..._buildTestCards(
                tests: state.tests
                    .where((test) => test.paperType == PyqPaperType.gs)
                    .toList(growable: false),
              ),
              const SectionHeader(title: 'CSAT Papers'),
              ..._buildTestCards(
                tests: state.tests
                    .where((test) => test.paperType == PyqPaperType.csat)
                    .toList(growable: false),
              ),
              if (state.history.isEmpty)
                const MetricCard(
                  label: 'Attempt History',
                  value: 'No attempts yet',
                  subtitle: 'Start your first PYQ full test.',
                )
              else
                ...state.history
                    .take(5)
                    .map(
                      (item) => MetricCard(
                        label:
                            'Attempt ${item.submittedAt.toLocal().toString().split('.').first}',
                        value:
                            '${item.correct}/${item.total} (${item.accuracyPercent.toStringAsFixed(1)}%)',
                        subtitle:
                            'Wrong ${item.wrong} • Unattempted ${item.unattempted} • Time ${(item.timeTakenSeconds / 60).toStringAsFixed(1)} mins',
                      ),
                    ),
              const SectionHeader(title: 'Question Bank Preview'),
              ...state.questions
                  .take(12)
                  .map(
                    (q) => Card(
                      child: ExpansionTile(
                        title: Text(
                          '[${q.year}] ${q.question.split('\n').first}',
                        ),
                        subtitle: Text(
                          '${q.subject} • ${q.chapter} • ${q.topicTag}',
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          12,
                        ),
                        children: [
                          Text(q.question),
                          const SizedBox(height: 8),
                          ...q.options.asMap().entries.map(
                            (entry) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${String.fromCharCode(65 + entry.key)}. ${entry.value}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Answer: ${String.fromCharCode(65 + q.correctIndex)}',
                          ),
                          const SizedBox(height: 4),
                          Text(q.explanation),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildTestCards({required List<PyqTestCatalogItem> tests}) {
    if (tests.isEmpty) {
      return const [
        Card(
          child: ListTile(
            title: Text('No papers available'),
            subtitle: Text('New papers will appear here when added.'),
          ),
        ),
      ];
    }

    return tests
        .map(
          (test) => Card(
            child: ListTile(
              title: Text(test.title),
              subtitle: Text(
                '${test.questionCount} questions • ${(test.durationSeconds / 60).toStringAsFixed(0)} mins\n'
                'Source: ${test.sourceName}\n'
                'Answer Key: ${test.isOfficialAnswerKey ? 'Official' : 'Expert (Unofficial)'}',
              ),
              trailing: const Icon(Icons.play_arrow_outlined),
              onTap: () {
                context.read<PyqTestCubit>().reset();
                context.push('/pyq/test/${test.testId}');
              },
            ),
          ),
        )
        .toList(growable: false);
  }
}
