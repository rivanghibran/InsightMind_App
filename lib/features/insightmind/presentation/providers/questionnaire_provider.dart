import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';

/// State: menyimpan jawaban pengguna dalam bentuk
/// map { id_pertanyaan : skor (0..3) }
class QuestionnaireState {
  final Map<String, int> answers;

  const QuestionnaireState({this.answers = const {}});

  QuestionnaireState copyWith({Map<String, int>? answers}) {
    return QuestionnaireState(answers: answers ?? this.answers);
  }

  /// Apakah semua pertanyaan sudah dijawab
  bool get isComplete => answers.length >= defaultQuestions.length;

  /// Jumlah total skor dari semua jawaban
  int get totalScore => answers.values.fold(0, (a, b) => a + b);
}

/// Notifier untuk mengelola logika form kuesioner
class QuestionnaireNotifier extends StateNotifier<QuestionnaireState> {
  QuestionnaireNotifier() : super(const QuestionnaireState());

  /// Memilih atau mengganti jawaban untuk satu pertanyaan
  void selectAnswer({required String questionId, required int score}) {
    final newMap = Map<String, int>.from(state.answers);
    newMap[questionId] = score;
    state = state.copyWith(answers: newMap);
  }

  /// Reset semua jawaban
  void reset() {
    state = const QuestionnaireState();
  }
}

/// Provider daftar pertanyaan (konstan)
final questionsProvider = Provider<List<Question>>((ref) {
  return defaultQuestions;
});

/// Provider state untuk kuesioner
final questionnaireProvider =
    StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>((ref) {
  return QuestionnaireNotifier();
});
