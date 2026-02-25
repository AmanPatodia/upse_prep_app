import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pyq_repository.dart';
import '../../domain/pyq_models.dart';

class PyqHomeState {
  const PyqHomeState({
    this.isLoading = false,
    this.error,
    this.questions = const [],
    this.tests = const [],
    this.history = const [],
  });

  final bool isLoading;
  final String? error;
  final List<PyqQuestion> questions;
  final List<PyqTestCatalogItem> tests;
  final List<PyqAttemptReport> history;

  PyqHomeState copyWith({
    bool? isLoading,
    String? error,
    List<PyqQuestion>? questions,
    List<PyqTestCatalogItem>? tests,
    List<PyqAttemptReport>? history,
  }) {
    return PyqHomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      questions: questions ?? this.questions,
      tests: tests ?? this.tests,
      history: history ?? this.history,
    );
  }
}

class PyqHomeCubit extends Cubit<PyqHomeState> {
  PyqHomeCubit(this._repository) : super(const PyqHomeState());

  final PyqRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _repository.getPyqs(),
        _repository.getAvailableTests(),
        _repository.getAttemptHistory(),
      ]);
      emit(
        state.copyWith(
          isLoading: false,
          questions: results[0] as List<PyqQuestion>,
          tests: results[1] as List<PyqTestCatalogItem>,
          history: results[2] as List<PyqAttemptReport>,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
