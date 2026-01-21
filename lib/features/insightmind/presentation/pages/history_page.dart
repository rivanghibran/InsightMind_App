import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/history_providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  // --- PALET WARNA UI ANDA ---
  final Color bgPurple = const Color(0xFF6C5CE7);
  final Color accentPink = const Color(0xFFFF7675);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textDark = const Color(0xFF2D3436);

  String _formatSimpleDate(DateTime date) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(date);
  }

  Color _getLevelColor(String level) {
    if (level.contains('Tinggi')) return const Color(0xFFE17055);
    if (level.contains('Sedang')) return const Color(0xFFFDCB6E);
    return const Color(0xFF00B894);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load data menggunakan provider
    final historyAsync = ref.watch(historyListProvider); 

    return Scaffold(
      backgroundColor: bgPurple, // Background Ungu
      appBar: AppBar(
        title: const Text(
          'Riwayat Screening',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Refresh Manual
           IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
            onPressed: () => ref.refresh(historyListProvider),
          ),
          // Tombol Hapus Semua (Logic dari gambar diterapkan ke UI Ungu)
          historyAsync.when(
            data: (data) => data.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Bersihkan Semua',
                    onPressed: () => _showClearConfirmation(context, ref),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        data: (history) {
          // Empty State (UI Ungu)
          if (history.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = history[index];
              final levelColor = _getLevelColor(item.riskLevel);

              // FITUR GESER UNTUK HAPUS (UI/UX Asli)
              // Digabungkan dengan Logic UUID Baru
              return Dismissible(
                // KUNCI UTAMA: Gunakan item.id (UUID) sebagai Key unik
                key: Key(item.id), 
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: accentPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  // LOGIKA BARU DARI GAMBAR: Panggil deleteById
                  await ref.read(historyRepositoryProvider).deleteById(item.id);
                  
                  // Refresh UI agar sinkron
                  ref.refresh(historyListProvider);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item dihapus')),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Badge Skor
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${item.score}',
                              style: TextStyle(
                                color: levelColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Info Utama
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Risiko ${item.riskLevel}',
                                style: TextStyle(
                                  color: textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Tampilkan Tanggal
                                _formatSimpleDate(item.timestamp),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // (Opsional) Tampilkan ID untuk debug jika mau, sesuai gambar
                              // Text("ID: ${item.id}", style: TextStyle(fontSize: 10, color: Colors.grey))
                            ],
                          ),
                        ),
                        
                        // Tombol Hapus Kecil (Opsional, pelengkap swipe)
                        IconButton(
                          icon: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                          onPressed: () async {
                             // Panggil fungsi deleteById logic baru
                             await ref.read(historyRepositoryProvider).deleteById(item.id);
                             ref.refresh(historyListProvider);
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget Tampilan Kosong (Sesuai Desain Ungu)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart, // Mengganti icon history_edu agar lebih fresh
              size: 64,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Data Kosong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lakukan screening minimal sekali\nuntuk melihat analitik.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus semua riwayat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentPink),
            onPressed: () async {
              // Panggil clearAll dari repository
              await ref.read(historyRepositoryProvider).clearAll();
              ref.refresh(historyListProvider);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}