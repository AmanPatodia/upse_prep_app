import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../domain/news_models.dart';
import 'bloc/news_cubit.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  _DateFilterMode _dateFilterMode = _DateFilterMode.all;
  DateTime? _customDate;
  String _selectedSource = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsCubit>().load();
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

  List<NewsItem> _applyDateFilter(List<NewsItem> items) {
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
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.items.isEmpty) {
          return Center(child: Text('Failed: ${state.error}'));
        }

        final dateFiltered = _applyDateFilter(state.items);
        final sourceOptions = <String>{
          'All',
          ...dateFiltered.map((e) => e.sourceName),
        }.toList(growable: false);
        final visible = dateFiltered
            .where((e) => _selectedSource == 'All' || e.sourceName == _selectedSource)
            .toList(growable: false);

        return SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 8),
              SectionHeader(
                title: 'Daily News Basics',
                action: TextButton.icon(
                  onPressed: () => context.read<NewsCubit>().load(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sources: Hindustan Times, Times of India, The Indian Express',
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
                      label: const Text('All Dates'),
                      selected: _dateFilterMode == _DateFilterMode.all,
                      onSelected: (_) => setState(() => _dateFilterMode = _DateFilterMode.all),
                    ),
                    ChoiceChip(
                      label: const Text('Today'),
                      selected: _dateFilterMode == _DateFilterMode.today,
                      onSelected: (_) => setState(() => _dateFilterMode = _DateFilterMode.today),
                    ),
                    ChoiceChip(
                      label: const Text('Yesterday'),
                      selected: _dateFilterMode == _DateFilterMode.yesterday,
                      onSelected: (_) => setState(() => _dateFilterMode = _DateFilterMode.yesterday),
                    ),
                    ChoiceChip(
                      label: const Text('Last 7 Days'),
                      selected: _dateFilterMode == _DateFilterMode.last7Days,
                      onSelected: (_) => setState(() => _dateFilterMode = _DateFilterMode.last7Days),
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
                      onSelected: (_) => setState(() => _selectedSource = source),
                    );
                  }).toList(growable: false),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Showing ${visible.length} of ${state.items.length} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ...visible.map((item) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Source: ${item.sourceName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMM yyyy').format(item.date.toLocal()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(item.summary),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => context.read<NewsCubit>().toggleBookmark(item.id),
                              icon: Icon(
                                item.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                              ),
                              label: const Text('Bookmark'),
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

enum _DateFilterMode { all, today, yesterday, last7Days, custom }
