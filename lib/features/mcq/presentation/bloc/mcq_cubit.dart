import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/mcq_repository.dart';
import '../../domain/mcq_models.dart';

class McqState {
  const McqState({
    this.isLoading = false,
    this.error,
    this.subjects = const [],
    this.chapters = const [],
    this.questions = const [],
    this.attemptHistory = const [],
    this.selectedSubject,
    this.selectedChapter,
    this.timedMode = true,
    this.selectedAnswers = const {},
  });

  final bool isLoading;
  final String? error;
  final List<String> subjects;
  final List<String> chapters;
  final List<McqQuestion> questions;
  final List<AttemptSummary> attemptHistory;
  final String? selectedSubject;
  final String? selectedChapter;
  final bool timedMode;
  final Map<String, int> selectedAnswers;

  McqState copyWith({
    bool? isLoading,
    String? error,
    List<String>? subjects,
    List<String>? chapters,
    List<McqQuestion>? questions,
    List<AttemptSummary>? attemptHistory,
    String? selectedSubject,
    String? selectedChapter,
    bool? timedMode,
    Map<String, int>? selectedAnswers,
  }) {
    return McqState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      subjects: subjects ?? this.subjects,
      chapters: chapters ?? this.chapters,
      questions: questions ?? this.questions,
      attemptHistory: attemptHistory ?? this.attemptHistory,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedChapter: selectedChapter ?? this.selectedChapter,
      timedMode: timedMode ?? this.timedMode,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class McqCubit extends Cubit<McqState> {
  McqCubit(this._repository) : super(const McqState());

  final McqRepository _repository;

  Future<void> load({String? initialSubject, String? initialChapter}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final subjects = await _repository.getSubjects();
      final selectedSubject = initialSubject;
      final chapters =
          (selectedSubject == null || selectedSubject.isEmpty)
              ? const <String>[]
              : await _repository.getChaptersBySubject(selectedSubject);
      final questions = await _repository.getSubjectMcqs(
        subject: selectedSubject,
        chapter: initialChapter,
      );
      final history = await _repository.getAttemptHistory();

      emit(
        state.copyWith(
          isLoading: false,
          subjects: subjects,
          chapters: chapters,
          questions: questions,
          attemptHistory: history,
          selectedSubject: selectedSubject,
          selectedChapter: initialChapter,
          selectedAnswers: {},
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> selectSubject(String? value) async {
    emit(
      state.copyWith(
        isLoading: true,
        selectedSubject: value,
        selectedChapter: null,
        selectedAnswers: {},
      ),
    );
    final chapters =
        (value == null || value.isEmpty)
            ? const <String>[]
            : await _repository.getChaptersBySubject(value);
    final questions = await _repository.getSubjectMcqs(subject: value);
    emit(
      state.copyWith(
        isLoading: false,
        chapters: chapters,
        questions: questions,
      ),
    );
  }

  Future<void> selectChapter(String? value) async {
    emit(
      state.copyWith(
        isLoading: true,
        selectedChapter: value,
        selectedAnswers: {},
      ),
    );
    final questions = await _repository.getSubjectMcqs(
      subject: state.selectedSubject,
      chapter: value,
    );
    emit(state.copyWith(isLoading: false, questions: questions));
  }

  void setTimedMode(bool value) => emit(state.copyWith(timedMode: value));

  void answer(String questionId, int answer) {
    final next = {...state.selectedAnswers, questionId: answer};
    emit(state.copyWith(selectedAnswers: next));
  }
}
