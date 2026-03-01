import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import 'bloc/mcq_cubit.dart';

class McqPracticeScreen extends StatefulWidget {
  const McqPracticeScreen({
    super.key,
    this.initialSubject,
    this.initialChapter,
  });

  final String? initialSubject;
  final String? initialChapter;

  @override
  State<McqPracticeScreen> createState() => _McqPracticeScreenState();
}

class _McqPracticeScreenState extends State<McqPracticeScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_initialized) return;
      _initialized = true;
      context.read<McqCubit>().load(
        initialSubject: widget.initialSubject,
        initialChapter: widget.initialChapter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<McqCubit, McqState>(
      builder: (context, state) {
        if (state.isLoading &&
            state.subjects.isEmpty &&
            state.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.questions.isEmpty) {
          return Center(child: Text('Failed: ${state.error}'));
        }

        return SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 8),
              SectionHeader(
                title: 'Prelims MCQs: Subject -> Chapter Wise',
                action: TextButton(
                  onPressed: () => context.push('/practice/mock'),
                  child: const Text('Full Mock Test'),
                ),
              ),
              SwitchListTile(
                title: const Text('Timed practice mode'),
                subtitle: const Text('Track speed and question-wise pacing'),
                value: state.timedMode,
                onChanged:
                    (value) => context.read<McqCubit>().setTimedMode(value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String?>(
                  isExpanded: true,
                  value: state.selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Select Subject',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'All Subjects',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    ...state.subjects.map(
                      (s) => DropdownMenuItem<String?>(
                        value: s,
                        child: Text(
                          s,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                  selectedItemBuilder:
                      (context) => [
                        const Text(
                          'All Subjects',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        ...state.subjects.map(
                          (s) => Text(
                            s,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                  onChanged:
                      (value) => context.read<McqCubit>().selectSubject(value),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String?>(
                  isExpanded: true,
                  value: state.selectedChapter,
                  decoration: const InputDecoration(
                    labelText: 'Select Chapter',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'All Chapters',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    ...state.chapters.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c,
                        child: Text(
                          c,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                  selectedItemBuilder:
                      (context) => [
                        const Text(
                          'All Chapters',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        ...state.chapters.map(
                          (c) => Text(
                            c,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                  onChanged:
                      state.selectedSubject == null
                          ? null
                          : (value) =>
                              context.read<McqCubit>().selectChapter(value),
                ),
              ),
              const SizedBox(height: 8),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(),
                ),
              if (state.questions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No MCQs found for this filter. Choose another subject/chapter.',
                      ),
                    ),
                  ),
                )
              else
                ...state.questions.map(
                  (q) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[${q.subject}] ${q.chapter}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            q.question,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ...q.options.asMap().entries.map(
                            (entry) => RadioListTile<int>(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(entry.value),
                              value: entry.key,
                              groupValue: state.selectedAnswers[q.id],
                              onChanged: (value) {
                                if (value == null) return;
                                context.read<McqCubit>().answer(q.id, value);
                              },
                            ),
                          ),
                          const Divider(),
                          Text(
                            'Difficulty: ${q.difficulty.name.toUpperCase()}',
                          ),
                          if (state.selectedAnswers.containsKey(q.id))
                            Text(
                              state.selectedAnswers[q.id] == q.correctIndex
                                  ? 'Correct'
                                  : 'Incorrect · ${q.explanation}',
                              style: TextStyle(
                                color:
                                    state.selectedAnswers[q.id] ==
                                            q.correctIndex
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                              ),
                            ),
                        ],
                      ),
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
}
