import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/pyq_test_cubit.dart';

class PyqTestScreen extends StatefulWidget {
  const PyqTestScreen({super.key, required this.testId});

  final String testId;

  @override
  State<PyqTestScreen> createState() => _PyqTestScreenState();
}

class _PyqTestScreenState extends State<PyqTestScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_started) return;
      _started = true;
      context.read<PyqTestCubit>().startTest(widget.testId);
    });
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PyqTestCubit, PyqTestState>(
      builder: (context, state) {
        final controller = context.read<PyqTestCubit>();

        if (state.loading) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        if (state.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('PYQ Full Test')),
            body: SafeArea(
              child: Center(child: Text('Failed: ${state.error}')),
            ),
          );
        }

        if (state.submitted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.pushReplacement('/pyq/result');
          });
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        final question = state.currentQuestion;
        if (question == null) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: Text('No questions available.')),
            ),
          );
        }

        final selected = state.answers[question.id];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'PYQ Test • Q ${state.currentIndex + 1}/${state.totalQuestions}',
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Chip(
                  avatar: const Icon(Icons.timer_outlined, size: 18),
                  label: Text(_formatTime(state.remainingSeconds)),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(state.totalQuestions, (index) {
                        final status = state.questionStatus(index);
                        final color = switch (status) {
                          PyqQuestionStatus.answered => Colors.green,
                          PyqQuestionStatus.notAnswered => Colors.orange,
                          PyqQuestionStatus.notVisited => Colors.grey,
                        };
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () => controller.jumpToQuestion(index),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  index == state.currentIndex
                                      ? Theme.of(context).colorScheme.primary
                                      : color,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        '[${question.year}] ${question.subject} • ${question.chapter}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.question,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...question.options.asMap().entries.map(
                        (entry) => RadioListTile<int>(
                          value: entry.key,
                          groupValue: selected,
                          onChanged: (value) {
                            if (value == null) return;
                            controller.selectOption(value);
                          },
                          title: Text(
                            '${String.fromCharCode(65 + entry.key)}. ${entry.value}',
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: controller.clearSelectedOption,
                            child: const Text('Clear Response'),
                          ),
                          OutlinedButton(
                            onPressed: controller.previousQuestion,
                            child: const Text('Previous'),
                          ),
                          FilledButton(
                            onPressed: controller.nextQuestion,
                            child: const Text('Save & Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FilledButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Submit Test?'),
                              content: const Text(
                                'You can still review answers after submitting.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                      );
                      if (confirmed == true) await controller.submitTest();
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Submit Test'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
