import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/score_provider.dart';
import 'package:hive/hive.dart';
import '../../data/local/screening_record.dart';

class ScreeningPage extends ConsumerWidget {
  const ScreeningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    final progress =
        questions.isEmpty ? 0.0 : (qState.answers.length / questions.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening InsightMind'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ===== PROGRESS BAR =====
          Container(
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.indigo.shade100,
                    color: Colors.indigo,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${qState.answers.length}/${questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),

          // ===== DAFTAR PERTANYAAN =====
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final q = questions[index];
                final selected = qState.answers[q.id];
                return _QuestionTile(
                  index: index,
                  question: q,
                  selectedScore: selected,
                  onSelected: (score) {
                    ref
                        .read(questionnaireProvider.notifier)
                        .selectAnswer(questionId: q.id, score: score);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ===== TOMBOL LIHAT HASIL & RESET =====
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol Lihat Hasil
            FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Lihat Hasil',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                if (!qState.isComplete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Lengkapi semua pertanyaan sebelum melihat hasil.'),
                    ),
                  );
                  return;
                }

                // ==== tampilkan popup ringkasan sebelum ke halaman hasil ====
                showDialog(
                  context: context,
                  builder: (_) => _SummaryDialog(
                    questions: questions,
                    answers: qState.answers,
                    onConfirm: () {
                      final ordered = <int>[];
                      for (final q in questions) {
                        ordered.add(qState.answers[q.id]!);
                      }
                      ref.read(answersProvider.notifier).state = ordered;

                      Navigator.of(context).pop(); // tutup dialog
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ResultPage()),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Tombol Reset Jawaban
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Jawaban'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo,
                side: const BorderSide(color: Colors.indigo),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                ref.read(questionnaireProvider.notifier).reset();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jawaban telah direset.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Result page: menampilkan hasil, daftar jawaban, dan opsi menyimpan ke riwayat
class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(answersProvider);
    final result = ref.watch(resultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Screening'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 64, color: Colors.indigo),
                    const SizedBox(height: 12),
                    Text('Skor: ${result.score}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 6),
                    Text('Level Risiko: ${result.level}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.indigo)),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Jawaban:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: answers.isEmpty
                          ? [const Chip(label: Text('Tidak ada jawaban'))]
                          : [for (final a in answers) Chip(label: Text('$a'))],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan Riwayat'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.indigo),
                            onPressed: answers.isEmpty
                                ? null
                                : () async {
                                    // Simpan ke provider riwayat (menggunakan Hive di dalam provider)
                                    ref.read(historyProvider.notifier).addRecord(
                                          date: DateTime.now(),
                                          answers: answers,
                                          score: result.score,
                                          level: result.level,
                                        );

                                    // Simpan juga ke box typed `screening_records` sebagai ScreeningRecord
                                    try {
                                      final box = Hive.box('screening_records');
                                      // create simple record with generated id
                                      final rec = ScreeningRecord(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        timestamp: DateTime.now(),
                                        score: result.score,
                                        riskLevel: result.level,
                                        note: answers.join(', '),
                                      );
                                      await box.add(rec);
                                    } catch (_) {}

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Disimpan ke riwayat')),
                                    );
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Kembali'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// ===== Widget Pertanyaan (RadioListTile) =====
// =============================================================
class _QuestionTile extends StatelessWidget {
  final int index;
  final Question question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  const _QuestionTile({
    required this.index,
    required this.question,
    required this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${index + 1}. ${question.text}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            for (final opt in question.options)
              RadioListTile<int>(
                title: Text(opt.label),
                value: opt.score,
                groupValue: selectedScore,
                onChanged: (value) {
                  if (value != null) onSelected(value);
                },
                activeColor: Colors.indigo,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ],
    );
  }
}

// =============================================================
// ===== POPUP RINGKASAN JAWABAN =====
// =============================================================
class _SummaryDialog extends StatelessWidget {
  final List<Question> questions;
  final Map<String, int> answers;
  final VoidCallback onConfirm;

  const _SummaryDialog({
    required this.questions,
    required this.answers,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          children: [
            // ===== Header =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ringkasan Jawaban',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ===== Isi Ringkasan =====
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                itemBuilder: (_, i) {
                  final q = questions[i];
                  final selectedScore = answers[q.id];
                  final selectedLabel = q.options
                      .firstWhere((opt) => opt.score == selectedScore)
                      .label;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ${q.text}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jawaban: $selectedLabel',
                          style: const TextStyle(color: Colors.indigo),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ===== Tombol Tutup & Lanjut =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.indigo,
                      ),
                      child: const Text('Lanjutkan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
