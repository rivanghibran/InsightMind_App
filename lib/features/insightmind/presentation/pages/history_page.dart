import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/score_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Screening'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Riwayat dibersihkan')),
              );
            },
            tooltip: 'Bersihkan Riwayat',
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('Belum ada riwayat.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = history[index];
                final dateStr = item['date'] as String? ?? '';
                final date = DateTime.tryParse(dateStr);
                final answers = (item['answers'] as List?)?.cast<int>() ?? <int>[];
                final score = item['score'] ?? 0;
                final level = item['level'] ?? '';

                return Card(
                  child: ListTile(
                    title: Text('Skor: $score — $level'),
                    subtitle: Text(
                        'Tanggal: ${date != null ? date.toLocal().toString() : dateStr}\nJawaban: ${answers.join(', ')}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref.read(historyProvider.notifier).deleteAt(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item dihapus')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
