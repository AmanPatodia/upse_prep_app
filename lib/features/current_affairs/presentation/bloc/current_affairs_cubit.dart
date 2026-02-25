import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/current_affairs_repository.dart';
import '../../domain/current_affairs_models.dart';

class CurrentAffairsState {
  const CurrentAffairsState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  final bool isLoading;
  final List<CurrentAffairItem> items;
  final String? error;

  CurrentAffairsState copyWith({
    bool? isLoading,
    List<CurrentAffairItem>? items,
    String? error,
  }) {
    return CurrentAffairsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class CurrentAffairsCubit extends Cubit<CurrentAffairsState> {
  CurrentAffairsCubit(this._repository) : super(const CurrentAffairsState());

  final CurrentAffairsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.getDailyItems();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
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
