import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../../settings/presentation/bloc/app_preferences_cubit.dart';
import '../domain/current_affairs_models.dart';
import 'bloc/current_affairs_cubit.dart';

class CurrentAffairsScreen extends StatefulWidget {
  const CurrentAffairsScreen({super.key});

  @override
  State<CurrentAffairsScreen> createState() => _CurrentAffairsScreenState();
}

class _CurrentAffairsScreenState extends State<CurrentAffairsScreen> {
  _DateFilterMode _dateFilterMode = _DateFilterMode.all;
  DateTime? _customDate;
  String _selectedSource = 'All';
  static const _dailyBasicSources = <String>{
    'Hindustan Times',
    'Times of India',
    'The Indian Express',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CurrentAffairsCubit>();
      cubit.load();
    });
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDate: _customDate ?? now,
    );
    if (selected == null) return;
    setState(() {
      _customDate = selected;
      _dateFilterMode = _DateFilterMode.custom;
    });
  }

  List<CurrentAffairItem> _applyDateFilter(List<CurrentAffairItem> items) {
    final now = DateTime.now();
    bool matches(DateTime date) {
      final local = date.toLocal();
      switch (_dateFilterMode) {
        case _DateFilterMode.all:
          return true;
        case _DateFilterMode.today:
          return _isSameDay(local, now);
        case _DateFilterMode.yesterday:
          return _isSameDay(local, now.subtract(const Duration(days: 1)));
        case _DateFilterMode.last7Days:
          final cutoff = now.subtract(const Duration(days: 7));
          return local.isAfter(cutoff);
        case _DateFilterMode.custom:
          return _customDate != null && _isSameDay(local, _customDate!);
      }
    }

    return items.where((e) => matches(e.date)).toList(growable: false);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
        final dateFilteredItems = _applyDateFilter(state.items);
        final sourceOptions = <String>{
          'All',
          ...dateFilteredItems
              .map((e) => (e.sourceName ?? '').trim())
              .where((e) => e.isNotEmpty),
        }.toList(growable: false);
        final visibleItems = dateFilteredItems
            .where(
              (e) =>
                  _selectedSource == 'All' || (e.sourceName ?? '') == _selectedSource,
            )
            .toList(growable: false);
        final dailyBasics = visibleItems
            .where((e) => _dailyBasicSources.contains(e.sourceName))
            .toList(growable: false);
        final upscItems = visibleItems
            .where((e) => !_dailyBasicSources.contains(e.sourceName))
            .toList(growable: false);
        final totalItems = state.items.length;

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
              if (state.syncStatus != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    state.syncStatus!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => context.read<CurrentAffairsCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Feed'),
                    ),
                  ],
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Feed warning: ${state.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _dateFilterMode == _DateFilterMode.all,
                      onSelected: (_) {
                        setState(() {
                          _dateFilterMode = _DateFilterMode.all;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Today'),
                      selected: _dateFilterMode == _DateFilterMode.today,
                      onSelected: (_) {
                        setState(() {
                          _dateFilterMode = _DateFilterMode.today;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Yesterday'),
                      selected: _dateFilterMode == _DateFilterMode.yesterday,
                      onSelected: (_) {
                        setState(() {
                          _dateFilterMode = _DateFilterMode.yesterday;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Last 7 Days'),
                      selected: _dateFilterMode == _DateFilterMode.last7Days,
                      onSelected: (_) {
                        setState(() {
                          _dateFilterMode = _DateFilterMode.last7Days;
                        });
                      },
                    ),
                    ActionChip(
                      label: Text(
                        _customDate == null
                            ? 'Pick Date'
                            : DateFormat('dd MMM yyyy').format(_customDate!),
                      ),
                      onPressed: _pickCustomDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sourceOptions.map((source) {
                    return ChoiceChip(
                      label: Text(source),
                      selected: _selectedSource == source,
                      onSelected: (_) {
                        setState(() {
                          _selectedSource = source;
                        });
                      },
                    );
                  }).toList(growable: false),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Showing ${visibleItems.length} of $totalItems items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (visibleItems.isEmpty && totalItems > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'No items for selected date filter.',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _dateFilterMode = _DateFilterMode.all;
                          });
                        },
                        child: const Text('Reset Filter'),
                      ),
                    ],
                  ),
                ),
              if (dailyBasics.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Daily News Basics (HT, TOI, Indian Express)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ...dailyBasics.map((effective) => _buildItemCard(context, effective)),
              ],
              if (upscItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'UPSC Current Affairs Sources',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ...upscItems.map((effective) => _buildItemCard(context, effective)),
              ],
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, CurrentAffairItem effective) {
    final prefs = context.watch<AppPreferencesCubit>().state;
    final body = Theme.of(context).textTheme.bodyMedium;
    final scaledBody = body?.copyWith(
      fontSize: (body.fontSize ?? 14) * prefs.fontScale,
      height: prefs.lineHeight,
    );
    final shortSummary = _shorten(effective.summary, maxChars: 220);
    final topTags = effective.tags.take(4).toList(growable: false);
    final topFacts = effective.facts.take(3).toList(growable: false);

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
            if ((effective.sourceName ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Source: ${effective.sourceName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 2),
            Text(
              DateFormat('dd MMM yyyy').format(effective.date.toLocal()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text('In Brief', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(shortSummary, style: scaledBody),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: topTags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(growable: false),
            ),
            if (topFacts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Key Points', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              ...topFacts.map((fact) => Text('• $fact', style: scaledBody)),
            ],
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
  }

  String _shorten(String text, {required int maxChars}) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= maxChars) return clean;
    return '${clean.substring(0, maxChars).trimRight()}...';
  }
}

enum _DateFilterMode { all, today, yesterday, last7Days, custom }
