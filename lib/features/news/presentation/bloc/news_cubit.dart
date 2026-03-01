import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../data/news_repository.dart';
import '../../domain/news_models.dart';

class NewsState {
  const NewsState({this.isLoading = false, this.items = const [], this.error});

  final bool isLoading;
  final List<NewsItem> items;
  final String? error;

  NewsState copyWith({
    bool? isLoading,
    List<NewsItem>? items,
    String? error,
  }) {
    return NewsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class NewsCubit extends Cubit<NewsState> {
  NewsCubit(this._repository) : super(const NewsState());

  final NewsRepository _repository;

  Future<void> load() async {
    AppLogger.info('NewsCubit', 'Loading news items');
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.getDailyNews();
      AppLogger.info('NewsCubit', 'Loaded ${items.length} news items');
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e, st) {
      AppLogger.error(
        'NewsCubit',
        'Failed to load news',
        error: e,
        stackTrace: st,
      );
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void toggleBookmark(String id) {
    final updated = state.items
        .map((e) => e.id == id ? e.copyWith(isBookmarked: !e.isBookmarked) : e)
        .toList(growable: false);
    emit(state.copyWith(items: updated));
  }
}
