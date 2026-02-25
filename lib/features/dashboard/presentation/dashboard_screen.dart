import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool focusMode = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const SectionHeader(title: 'UPSC Prep Dashboard'),
          FocusModeBanner(enabled: focusMode),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push('/prelims'),
                  icon: const Icon(Icons.track_changes_outlined),
                  label: const Text('Prelims'),
                ),
                FilledButton.icon(
                  onPressed: () => context.push('/mains'),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Mains'),
                ),
                FilledButton.icon(
                  onPressed: () => context.push('/practice/mcq'),
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Prelims MCQs'),
                ),
                FilledButton.icon(
                  onPressed: () => context.push('/current-affairs'),
                  icon: const Icon(Icons.newspaper_outlined),
                  label: const Text('Current Affairs'),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Focus mode'),
            subtitle: const Text(
              'Simplifies UI, reduces non-essential interactions',
            ),
            value: focusMode,
            onChanged: (value) => setState(() => focusMode = value),
          ),
          const MetricCard(
            label: 'Today plan',
            value: '6 tasks',
            subtitle: '2 complete • 4 pending',
          ),
          const MetricCard(
            label: 'Revision queue',
            value: '14 topics',
            subtitle: 'Priority: Polity, Economy',
          ),
          const MetricCard(
            label: 'Weekly progress',
            value: '74%',
            subtitle: 'On track for target completion',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
