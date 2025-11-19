import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/score_provider.dart';
import 'screening_page.dart';
import 'history_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(answersProvider);
    final result = ref.watch(resultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InsightMind'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Screening',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.psychology_alt,
                      size: 60, color: Colors.indigo),
                  const SizedBox(height: 16),
                  const Text(
                    'Selamat Datang di InsightMind',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulai screening sederhana untuk memprediksi risiko kesehatan mental secara cepat dan mudah.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScreeningPage(),
                        ),
                      );
                    },
                    child: const Text('Mulai Screening'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tampilan hasil terkini (jika ada jawaban)
          if (answers.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Hasil Terakhir',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Skor: ${result.score}'),
                    const SizedBox(height: 4),
                    Text('Level Risiko: ${result.level}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            // simpan ke riwayat
                            ref.read(historyProvider.notifier).addRecord(
                                  date: DateTime.now(),
                                  answers: answers,
                                  score: result.score,
                                  level: result.level,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Disimpan ke riwayat')),
                            );
                          },
                          child: const Text('Simpan ke Riwayat'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.tonal(
                          onPressed: () {
                            // hapus jawaban saat ini
                            ref.read(answersProvider.notifier).clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Jawaban direset')),
                            );
                          },
                          child: const Text('Reset Jawaban'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          if (answers.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Riwayat Simulasi Minggu 2',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final a in answers) Chip(label: Text('$a')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {
          final newValue =
              (DateTime.now().millisecondsSinceEpoch % 4).toInt();
          // gunakan method provider agar otomatis tersimpan ke Hive
          ref.read(answersProvider.notifier).addAnswer(newValue);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
