import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import 'bloc/ai_cubit.dart';

class AiUpdatesScreen extends StatefulWidget {
  const AiUpdatesScreen({super.key});

  @override
  State<AiUpdatesScreen> createState() => _AiUpdatesScreenState();
}

class _AiUpdatesScreenState extends State<AiUpdatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AiCubit>();
      if (cubit.state.items.isEmpty) cubit.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiCubit, AiState>(
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
              const SectionHeader(title: 'AI Assistant & Smart Updates'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => context.push('/current-affairs'),
                      child: const Text('Current Affairs'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => context.push('/pyq'),
                      child: const Text('PYQ Practice'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...state.items.map(
                (update) => Card(
                  child: ListTile(
                    title: Text(update.title),
                    subtitle: Text(update.content),
                    trailing: Text(update.type.name),
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
