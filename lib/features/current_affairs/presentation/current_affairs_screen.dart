import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import 'bloc/current_affairs_cubit.dart';

class CurrentAffairsScreen extends StatefulWidget {
  const CurrentAffairsScreen({super.key});

  @override
  State<CurrentAffairsScreen> createState() => _CurrentAffairsScreenState();
}

class _CurrentAffairsScreenState extends State<CurrentAffairsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CurrentAffairsCubit>();
      if (cubit.state.items.isEmpty) cubit.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentAffairsCubit, CurrentAffairsState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.items.isEmpty) {
          return Center(child: Text('Failed: ${state.error}'));
        }

        return SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 8),
              SectionHeader(
                title: 'Daily Current Affairs',
                action: TextButton(
                  onPressed: () => context.push('/ai'),
                  child: const Text('AI Summary'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Offline cache enabled • Monthly compilation generated on sync.',
                ),
              ),
              ...state.items.map((effective) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          effective.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(effective.summary),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: effective.tags
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 8),
                        ...effective.facts.map((fact) => Text('• $fact')),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed:
                                  () => context
                                      .read<CurrentAffairsCubit>()
                                      .toggleBookmark(effective.id),
                              icon: Icon(
                                effective.isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                              ),
                              label: const Text('Bookmark'),
                            ),
                            TextButton.icon(
                              onPressed:
                                  () => context
                                      .read<CurrentAffairsCubit>()
                                      .toggleReviseLater(effective.id),
                              icon: Icon(
                                effective.reviseLater
                                    ? Icons.check_circle
                                    : Icons.schedule,
                              ),
                              label: const Text('Revise Later'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
