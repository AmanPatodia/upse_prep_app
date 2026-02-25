import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import 'bloc/subjects_cubit.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<SubjectsCubit>();
      if (cubit.state.subjects.isEmpty) {
        cubit.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectsCubit, SubjectsState>(
      builder: (context, state) {
        if (state.isLoading && state.subjects.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.subjects.isEmpty) {
          return Center(child: Text('Failed: ${state.error}'));
        }

        return SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const SectionHeader(title: 'Subjects -> Chapters -> Topics'),
              ...state.subjects.map(
                (subject) => Card(
                  child: ExpansionTile(
                    title: Text(subject.name),
                    subtitle: Text('${subject.chapters.length} chapters'),
                    children: [
                      for (final chapter in subject.chapters)
                        ExpansionTile(
                          title: Text(chapter.title),
                          subtitle: Text('${chapter.topics.length} topics'),
                          children: [
                            for (final topic in chapter.topics)
                              ListTile(
                                title: Text(topic.title),
                                subtitle: Text(
                                  topic.importantPoints.join(' • '),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap:
                                    () => context.push(
                                      '/subjects/topic/${topic.id}',
                                    ),
                              ),
                          ],
                        ),
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
}
