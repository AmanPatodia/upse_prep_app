import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';

class PrelimsOverviewScreen extends StatelessWidget {
  const PrelimsOverviewScreen({super.key});

  static const prelimsSyllabus = {
    'History': [
      'Ancient India',
      'Medieval India',
      'Modern India',
      'Indian National Movement',
      'Art and Culture',
    ],
    'Geography': [
      'Physical Geography',
      'Indian Geography',
      'World Geography',
      'Resources and Industries',
      'Environment and Ecology Linkages',
    ],
    'Indian Polity and Governance': [
      'Constitutional Framework',
      'Fundamental Rights and Duties',
      'Union and State Government',
      'Parliament and State Legislature',
      'Judiciary',
      'Constitutional and Statutory Bodies',
    ],
    'Economy': [
      'National Income',
      'Inflation and Monetary Policy',
      'Fiscal Policy and Budget',
      'Banking and Financial Markets',
      'External Sector',
      'Government Schemes and Sectors',
    ],
    'Environment and Ecology': [
      'Ecosystems and Biodiversity',
      'Climate Change',
      'Pollution and Conservation',
      'Environmental Conventions',
      'Protected Areas in India',
    ],
    'General Science and Science Tech': [
      'Basic Physics Chemistry Biology',
      'Biotechnology',
      'Space and Defense Technology',
      'Computer and AI Basics',
      'Health and Disease',
    ],
    'Current Affairs': [
      'National Events',
      'International Relations',
      'Economy Current Affairs',
      'Environment Current Affairs',
      'Science and Tech Current Affairs',
    ],
    'CSAT Aptitude': [
      'Comprehension',
      'Logical Reasoning and Analytical Ability',
      'Decision Making and Problem Solving',
      'Basic Numeracy',
      'Data Interpretation',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const SectionHeader(title: 'Prelims Section'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Static syllabus structure based on UPSC-aligned coverage used by Vajiram & Ravi and Drishti IAS syllabus pages.',
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push('/practice/mcq'),
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Practice MCQs'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/practice/mock'),
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Full Mock Test'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/pyq'),
                  icon: const Icon(Icons.history_edu_outlined),
                  label: const Text('Prelims PYQs'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...prelimsSyllabus.entries.map(
            (entry) => Card(
              child: ExpansionTile(
                title: Text(entry.key),
                subtitle: Text('${entry.value.length} chapters'),
                trailing: TextButton(
                  onPressed:
                      () => context.push(
                        '/practice/mcq?subject=${Uri.encodeComponent(entry.key)}',
                      ),
                  child: const Text('Solve MCQs'),
                ),
                children: [
                  for (final chapter in entry.value)
                    ListTile(
                      title: Text(chapter),
                      trailing: const Icon(Icons.chevron_right),
                      onTap:
                          () => context.push(
                            '/practice/mcq?subject=${Uri.encodeComponent(entry.key)}&chapter=${Uri.encodeComponent(chapter)}',
                          ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
