import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../data/current_affairs_repository.dart';
import '../../domain/current_affairs_models.dart';

class CurrentAffairsState {
  const CurrentAffairsState({
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.syncStatus,
  });

  final bool isLoading;
  final List<CurrentAffairItem> items;
  final String? error;
  final String? syncStatus;

  CurrentAffairsState copyWith({
    bool? isLoading,
    List<CurrentAffairItem>? items,
    String? error,
    String? syncStatus,
  }) {
    return CurrentAffairsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class CurrentAffairsCubit extends Cubit<CurrentAffairsState> {
  CurrentAffairsCubit(this._repository) : super(const CurrentAffairsState());

  final CurrentAffairsRepository _repository;

  Future<void> load() async {
    AppLogger.info('CurrentAffairsCubit', 'Loading current affairs...');
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await _repository.getDailyItems();
      final syncStatus = result.source == CurrentAffairsDataSource.firestore
          ? 'Updated from Firestore'
          : 'Loaded from Hive cache';
      AppLogger.info(
        'CurrentAffairsCubit',
        'Loaded ${result.items.length} current affairs items',
      );
      emit(
        state.copyWith(
          isLoading: false,
          items: result.items,
          syncStatus: syncStatus,
        ),
      );
    } catch (e) {
      AppLogger.error(
        'CurrentAffairsCubit',
        'Failed to load current affairs',
        error: e,
      );
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
          syncStatus: state.syncStatus ?? 'Sync failed',
        ),
      );
    }
  }

  void toggleBookmark(String id) {
    final updated = state.items
        .map((e) => e.id == id ? e.copyWith(isBookmarked: !e.isBookmarked) : e)
        .toList(growable: false);
    emit(state.copyWith(items: updated));
  }

  void toggleReviseLater(String id) {
    final updated = state.items
        .map((e) => e.id == id ? e.copyWith(reviseLater: !e.reviseLater) : e)
        .toList(growable: false);
    emit(state.copyWith(items: updated));
  }
}
