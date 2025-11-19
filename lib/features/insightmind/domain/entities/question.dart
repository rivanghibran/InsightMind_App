class AnswerOption {
  final String label; // Contoh: "Tidak Pernah", "Beberapa Hari", ...
  final int score;    // Rentang 0..3

  const AnswerOption({
    required this.label,
    required this.score,
  });
}

class Question {
  final String id;
  final String text;
  final List<AnswerOption> options;

  const Question({
    required this.id,
    required this.text,
    required this.options,
  });
}

/// Contoh 9 pertanyaan gaya PHQ/DASS (parafrase; bukan kutipan verbatim)
const defaultQuestions = <Question>[
  Question(
    id: 'q1',
    text: 'Dalam 2 minggu terakhir, seberapa sering Anda merasa sedih atau murung?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q2',
    text: 'Kesulitan menikmati hal-hal yang biasanya menyenangkan?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q3',
    text: 'Apakah Anda merasa sulit tidur atau sering terbangun di malam hari?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q4',
    text: 'Merasa mudah lelah atau kekurangan energi tanpa alasan yang jelas?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q5',
    text: 'Merasa tidak percaya diri, gagal, atau mengecewakan orang lain?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q6',
    text: 'Kesulitan berkonsentrasi pada tugas atau aktivitas sehari-hari?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q7',
    text: 'Merasa gelisah, tegang, atau sulit untuk rileks?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q8',
    text: 'Merasa takut sesuatu yang buruk akan terjadi tanpa alasan jelas?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q9',
    text: 'Merasa sangat lelah atau kurang energi dalam aktivitas sehari-hari?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
];

