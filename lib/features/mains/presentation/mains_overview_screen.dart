import 'package:flutter/material.dart';

import '../../../shared/widgets/common_widgets.dart';

class MainsOverviewScreen extends StatelessWidget {
  const MainsOverviewScreen({super.key});

  static const mainsStructure = {
    'Qualifying Papers': ['Paper A: Indian Language', 'Paper B: English'],
    'Essay': ['Essay Paper (2 sections)'],
    'GS Paper I': [
      'Indian Heritage and Culture',
      'Modern Indian History',
      'World History',
      'Indian Society',
      'Geography of World and India',
    ],
    'GS Paper II': [
      'Constitution and Polity',
      'Governance and Welfare',
      'Social Justice',
      'International Relations',
    ],
    'GS Paper III': [
      'Indian Economy',
      'Science and Technology',
      'Environment and Biodiversity',
      'Disaster Management',
      'Internal Security',
    ],
    'GS Paper IV': [
      'Ethics and Human Interface',
      'Attitude and Aptitude',
      'Emotional Intelligence',
      'Public Service Values',
      'Case Studies',
    ],
    'Optional Subject': [
      'Paper I',
      'Paper II',
      'Subject-specific advanced syllabus',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const SectionHeader(title: 'Mains Section'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Separate mains planning area for descriptive preparation, answer writing, and paper-wise strategy.',
            ),
          ),
          const SizedBox(height: 8),
          ...mainsStructure.entries.map(
            (entry) => Card(
              child: ExpansionTile(
                title: Text(entry.key),
                subtitle: Text('${entry.value.length} topics'),
                children: [
                  for (final topic in entry.value)
                    ListTile(
                      title: Text(topic),
                      leading: const Icon(Icons.task_alt_outlined),
                    ),
                ],
              ),
            ),
          ),
          const MetricCard(
            label: 'Mains Practice Block',
            value: 'Answer Writing Planner',
            subtitle:
                'Next step: add daily question, evaluator, and model answer comparison.',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
