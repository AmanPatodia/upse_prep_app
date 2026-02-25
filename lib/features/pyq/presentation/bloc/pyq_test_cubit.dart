import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pyq_repository.dart';
import '../../domain/pyq_models.dart';

enum PyqQuestionStatus { notVisited, notAnswered, answered }

class PyqTestState {
  const PyqTestState({
    this.loading = false,
    this.error,
    this.paper,
    this.currentIndex = 0,
    this.answers = const {},
    this.visited = const {},
    this.elapsedSeconds = 0,
    this.submitted = false,
    this.report,
  });

  final bool loading;
  final String? error;
  final PyqTestPaper? paper;
  final int currentIndex;
  final Map<String, int> answers;
  final Set<String> visited;
  final int elapsedSeconds;
  final bool submitted;
  final PyqAttemptReport? report;

  int get totalQuestions => paper?.questions.length ?? 0;
  int get durationSeconds => paper?.durationSeconds ?? 0;
  int get remainingSeconds =>
      (durationSeconds - elapsedSeconds).clamp(0, durationSeconds);

  PyqQuestion? get currentQuestion {
    final p = paper;
    if (p == null || p.questions.isEmpty) return null;
    return p.questions[currentIndex];
  }

  PyqQuestionStatus questionStatus(int index) {
    final p = paper;
    if (p == null || index < 0 || index >= p.questions.length) {
      return PyqQuestionStatus.notVisited;
    }
    final id = p.questions[index].id;
    if (answers.containsKey(id)) return PyqQuestionStatus.answered;
    if (visited.contains(id)) return PyqQuestionStatus.notAnswered;
    return PyqQuestionStatus.notVisited;
  }

  PyqTestState copyWith({
    bool? loading,
    String? error,
    PyqTestPaper? paper,
    int? currentIndex,
    Map<String, int>? answers,
    Set<String>? visited,
    int? elapsedSeconds,
    bool? submitted,
    PyqAttemptReport? report,
  }) {
    return PyqTestState(
      loading: loading ?? this.loading,
      error: error,
      paper: paper ?? this.paper,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      visited: visited ?? this.visited,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      submitted: submitted ?? this.submitted,
      report: report ?? this.report,
    );
  }
}

class PyqTestCubit extends Cubit<PyqTestState> {
  PyqTestCubit(this._repository) : super(const PyqTestState());

  final PyqRepository _repository;
  Timer? _timer;

  Future<void> startTest(String testId) async {
    _timer?.cancel();
    emit(const PyqTestState(loading: true));
    try {
      final paper = await _repository.getTestById(testId);
      final firstVisited =
          paper.questions.isEmpty ? <String>{} : {paper.questions.first.id};
      emit(PyqTestState(loading: false, paper: paper, visited: firstVisited));
      _startTimer();
    } catch (e) {
      emit(PyqTestState(loading: false, error: e.toString()));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.submitted || state.paper == null) {
        timer.cancel();
        return;
      }
      final nextElapsed = state.elapsedSeconds + 1;
      if (nextElapsed >= state.durationSeconds) {
        emit(state.copyWith(elapsedSeconds: state.durationSeconds));
        submitTest();
      } else {
        emit(state.copyWith(elapsedSeconds: nextElapsed));
      }
    });
  }

  void selectOption(int optionIndex) {
    final q = state.currentQuestion;
    if (q == null || state.submitted) return;
    emit(state.copyWith(answers: {...state.answers, q.id: optionIndex}));
  }

  void clearSelectedOption() {
    final q = state.currentQuestion;
    if (q == null || state.submitted) return;
    final next = {...state.answers}..remove(q.id);
    emit(state.copyWith(answers: next));
  }

  void nextQuestion() {
    final p = state.paper;
    if (p == null ||
        state.submitted ||
        state.currentIndex >= p.questions.length - 1) {
      return;
    }
    final nextIndex = state.currentIndex + 1;
    emit(
      state.copyWith(
        currentIndex: nextIndex,
        visited: {...state.visited, p.questions[nextIndex].id},
      ),
    );
  }

  void previousQuestion() {
    final p = state.paper;
    if (p == null || state.submitted || state.currentIndex == 0) return;
    emit(state.copyWith(currentIndex: state.currentIndex - 1));
  }

  void jumpToQuestion(int index) {
    final p = state.paper;
    if (p == null ||
        state.submitted ||
        index < 0 ||
        index >= p.questions.length) {
      return;
    }
    emit(
      state.copyWith(
        currentIndex: index,
        visited: {...state.visited, p.questions[index].id},
      ),
    );
  }

  Future<void> submitTest() async {
    final p = state.paper;
    if (p == null || state.submitted) return;
    _timer?.cancel();
    final report = await _repository.evaluateAttempt(
      testPaper: p,
      answers: state.answers,
      timeTakenSeconds: state.elapsedSeconds,
    );
    await _repository.saveAttempt(report);
    emit(state.copyWith(submitted: true, report: report));
  }

  void reset() {
    _timer?.cancel();
    emit(const PyqTestState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
