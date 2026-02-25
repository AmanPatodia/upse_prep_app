import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../domain/subject_models.dart';
import 'bloc/subjects_cubit.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key, required this.topicId});

  final String topicId;

  Color _priorityColor(BuildContext context, RevisionPriority priority) {
    return switch (priority) {
      RevisionPriority.low => Colors.green,
      RevisionPriority.medium => Colors.orange,
      RevisionPriority.high => Theme.of(context).colorScheme.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SubjectsCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Topic Notes')),
      body: FutureBuilder(
        future: cubit.topicById(topicId),
        builder: (context, snapshot) {
          if (!snapshot.hasData &&
              snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed: ${snapshot.error}'));
          }

          final topic = snapshot.data;
          if (topic == null) {
            return const Center(child: Text('Topic not found'));
          }

          return ListView(
            children: [
              const SizedBox(height: 8),
              SectionHeader(
                title: topic.title,
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_border),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.highlight_alt_outlined),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Chip(
                  avatar: CircleAvatar(
                    backgroundColor: _priorityColor(
                      context,
                      topic.revisionPriority,
                    ),
                    radius: 6,
                  ),
                  label: Text('Revision: ${topic.revisionPriority.name}'),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(topic.notes),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important points',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...topic.importantPoints.map((point) => Text('• $point')),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book references',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...topic.bookReferences.map((ref) => Text('• $ref')),
                    ],
                  ),
                ),
              ),
              if (topic.pdfUrl != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: const Text('Attached PDF'),
                    subtitle: Text(topic.pdfUrl!),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
