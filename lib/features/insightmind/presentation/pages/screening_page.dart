import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import domain & data
import '../../domain/entities/question.dart';
import '../../data/local/screening_record.dart'; // Model Hive

// Import Providers
import '../providers/questionnaire_provider.dart';
import '../providers/score_provider.dart';
import '../providers/history_providers.dart'; // Provider Repository

// =============================================================
// ===== HALAMAN 1: SCREENING PAGE (UI: Ungu + Hijau) =====
// =============================================================
class ScreeningPage extends ConsumerWidget {
  const ScreeningPage({super.key});

  // Palet Warna
  final Color bgPurple = const Color(0xFF6C5CE7);
  final Color accentPink = const Color(0xFFFF7675);
  final Color selectionGreen = const Color(0xFF81C784); // Hijau untuk jawaban

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    final progress = questions.isEmpty
        ? 0.0
        : (qState.answers.length / questions.length);

    return Scaffold(
      backgroundColor: bgPurple,
      appBar: AppBar(
        title: const Text(
          'Screening InsightMind',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ===== PROGRESS SECTION =====
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress",
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                    Text(
                      '${qState.answers.length} / ${questions.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black.withOpacity(0.2),
                    color: accentPink,
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),

          // ===== DAFTAR PERTANYAAN =====
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final selected = qState.answers[q.id];
                    return _QuestionTile(
                      index: index,
                      question: q,
                      selectedScore: selected,
                      accentColor: bgPurple,
                      selectionColor: selectionGreen,
                      onSelected: (score) {
                        if (selected == score) {
                          ref
                              .read(questionnaireProvider.notifier)
                              .removeAnswer(q.id);
                        } else {
                          ref
                              .read(questionnaireProvider.notifier)
                              .selectAnswer(questionId: q.id, score: score);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),

      // ===== TOMBOL LIHAT HASIL =====
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!qState.isComplete) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Lengkapi semua pertanyaan sebelum melihat hasil.',
                        ),
                        backgroundColor: accentPink,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  // Tampilkan Popup Ringkasan
                  showDialog(
                    context: context,
                    builder: (_) => _SummaryDialog(
                      questions: questions,
                      answers: qState.answers,
                      bgPurple: bgPurple,
                      accentPink: accentPink,
                      onConfirm: () {
                        // 1. Simpan jawaban ke state global untuk ResultPage
                        final ordered = <int>[];
                        for (final q in questions) {
                          ordered.add(qState.answers[q.id]!);
                        }
                        ref.read(answersProvider.notifier).state = ordered;

                        // 2. Navigasi ke Result Page
                        Navigator.of(context).pop(); // Tutup dialog
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ResultPage()),
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: accentPink.withOpacity(0.4),
                ),
                child: const Text(
                  'Lihat Hasil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: Icon(Icons.refresh, color: bgPurple),
                label: Text('Reset Jawaban', style: TextStyle(color: bgPurple)),
                onPressed: () {
                  ref.read(questionnaireProvider.notifier).reset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jawaban telah direset.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// ===== WIDGET: TILE PERTANYAAN =====
// =============================================================
class _QuestionTile extends StatelessWidget {
  final int index;
  final Question question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;
  final Color accentColor;
  final Color selectionColor;

  const _QuestionTile({
    required this.index,
    required this.question,
    required this.selectedScore,
    required this.onSelected,
    required this.accentColor,
    required this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: question.options.map((opt) {
            final isSelected = selectedScore == opt.score;
            return GestureDetector(
              onTap: () => onSelected(opt.score),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? selectionColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? selectionColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: selectionColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// =============================================================
// ===== WIDGET: POPUP RINGKASAN =====
// =============================================================
class _SummaryDialog extends StatelessWidget {
  final List<Question> questions;
  final Map<String, int> answers;
  final VoidCallback onConfirm;
  final Color bgPurple;
  final Color accentPink;

  const _SummaryDialog({
    required this.questions,
    required this.answers,
    required this.onConfirm,
    required this.bgPurple,
    required this.accentPink,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 550),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: bgPurple,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ringkasan Jawaban',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: questions.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (_, i) {
                  final q = questions[i];
                  final selectedScore = answers[q.id];
                  final selectedLabel = q.options
                      .firstWhere((opt) => opt.score == selectedScore)
                      .label;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedLabel,
                              style: TextStyle(
                                color: accentPink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Simpan & Lihat Hasil'),
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
// ===== HALAMAN 2: RESULT PAGE (Hive Integrated) =====
// =============================================================
class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  final Color bgPurple = const Color(0xFF6C5CE7);
  final Color accentPink = const Color(0xFFFF7675);
  final Color cardWhite = const Color(0xFFFFFFFF);

  // State untuk mencegah double save dan loading
  bool _isSaving = false;
  bool _hasSaved = false;

  @override
  Widget build(BuildContext context) {
    final answers = ref.watch(answersProvider);
    final result = ref.watch(resultProvider);

    return Scaffold(
      backgroundColor: bgPurple,
      appBar: AppBar(
        title: const Text(
          'Hasil Screening',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: bgPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology_alt,
                      size: 50,
                      color: bgPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SKOR ANDA',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${result.score}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Risiko ${result.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Riwayat Jawaban:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: answers.isEmpty
                        ? [const Chip(label: Text('Tidak ada jawaban'))]
                        : [
                            for (int i = 0; i < answers.length; i++)
                              Chip(
                                label: Text('${i + 1}: ${answers[i]}'),
                                backgroundColor: bgPurple.withOpacity(0.05),
                                labelStyle: TextStyle(color: bgPurple),
                              ),
                          ],
                  ),
                  const SizedBox(height: 32),

                  // ===== TOMBOL SIMPAN KE RIWAYAT =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _hasSaved ? 'Tersimpan' : 'Simpan ke Riwayat',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasSaved ? Colors.grey : bgPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: (_isSaving || _hasSaved || answers.isEmpty)
                          ? null
                          : () async {
                              setState(() => _isSaving = true);

                              try {
                                // 1. Simpan ke Hive (Tidak terpengaruh reset di bawah)
                                await ref
                                    .read(historyRepositoryProvider)
                                    .addRecord(
                                      score: result.score,
                                      riskLevel: result.level,
                                      note: answers.join(', '),
                                    );

                                // 2. Refresh List Riwayat agar Dashboard update
                                ref.invalidate(historyListProvider);

                                if (context.mounted) {
                                  setState(() {
                                    _isSaving = false;
                                    _hasSaved = true;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Berhasil disimpan ke Hive!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() => _isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal menyimpan: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // ===== TOMBOL KEMBALI (DENGAN RESET) =====
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      child: const Text('Kembali ke Menu'),
                      onPressed: () {
                        // [MODIFIKASI] Reset state kuesioner sebelum kembali
                        // Ini hanya membersihkan state di RAM (ScreeningPage)
                        // Data yang sudah disimpan ke Hive di tombol "Simpan" aman.
                        ref.read(questionnaireProvider.notifier).reset();

                        // Kembali ke halaman utama (bersihkan stack)
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
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