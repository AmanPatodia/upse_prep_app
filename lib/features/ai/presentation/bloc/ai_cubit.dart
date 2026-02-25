import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/ai_engine.dart';
import '../../domain/ai_models.dart';

class AiState {
  const AiState({this.isLoading = false, this.items = const [], this.error});

  final bool isLoading;
  final List<AiUpdate> items;
  final String? error;

  AiState copyWith({bool? isLoading, List<AiUpdate>? items, String? error}) {
    return AiState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class AiCubit extends Cubit<AiState> {
  AiCubit(this._engine) : super(const AiState());

  final AiEngine _engine;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _engine.fetchSmartUpdates();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
