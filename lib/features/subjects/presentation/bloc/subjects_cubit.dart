import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/subjects_repository.dart';
import '../../domain/subject_models.dart';

class SubjectsState {
  const SubjectsState({
    this.isLoading = false,
    this.subjects = const [],
    this.error,
  });

  final bool isLoading;
  final List<Subject> subjects;
  final String? error;

  SubjectsState copyWith({
    bool? isLoading,
    List<Subject>? subjects,
    String? error,
  }) {
    return SubjectsState(
      isLoading: isLoading ?? this.isLoading,
      subjects: subjects ?? this.subjects,
      error: error,
    );
  }
}

class SubjectsCubit extends Cubit<SubjectsState> {
  SubjectsCubit(this._repository) : super(const SubjectsState());

  final SubjectsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final subjects = await _repository.getSubjects();
      emit(state.copyWith(isLoading: false, subjects: subjects));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<Topic?> topicById(String topicId) => _repository.getTopicById(topicId);
}
