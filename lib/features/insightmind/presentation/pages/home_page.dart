import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import HistoryPage yang diasumsikan berada di lokasi yang sama
import 'history_page.dart'; 
import '../providers/score_provider.dart';
import 'screening_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(answersProvider);
    final history = ref.watch(historyProvider); 
    
    // 👇 BARU: Ambil hasil dari answersProvider yang tersimpan sementara
    final result = ref.watch(resultProvider); 
    
    final hasHistory = history.isNotEmpty; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('InsightMind'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 Kartu utama: sambutan & tombol mulai screening (TIDAK BERUBAH)
          // ... (Kode Kartu Selamat Datang) ...
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Colors.indigo.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology_alt,
                    size: 60,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selamat Datang di InsightMind',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulai screening sederhana untuk memprediksi risiko '
                    'kesehatan mental Anda secara cepat dan mudah.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScreeningPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Mulai Screening',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          
          // --- Kartu Riwayat Lengkap (TIDAK BERUBAH) ---
          if (hasHistory)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.indigo),
                title: Text('Riwayat Screening Lengkap'),
                subtitle: Text('Tersimpan ${history.length} hasil screening.'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryPage(), 
                    ),
                  );
                },
              ),
            ),
          
          if (hasHistory) 
            const SizedBox(height: 24),

          // 🔹 Kartu Jawaban Screening Terakhir (DIUBAH)
          if (answers.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4, // Tingkatkan elevasi sedikit
              shadowColor: Colors.amber.withOpacity(0.3), // Warna bayangan yang berbeda
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // JUDUL DAN STATUS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hasil Screening Terakhir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 20),
                    
                    // SKOR DAN LEVEL
                    Row(
                      children: [
                        // Kotak Skor
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text('SKOR', style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w500)),
                              Text('${result.score}', 
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Level Risiko
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Level Risiko:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              Text(result.level,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  // Warna berbeda berdasarkan level (opsional)
                                  color: result.level == 'Tinggi' ? Colors.red : Colors.green.shade700,
                                )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 20),
                    
                    // DETAIL JAWABAN
                    const Text('Detail Jawaban:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final a in answers)
                          Chip(
                            label: Text('$a'),
                            backgroundColor: Colors.indigo.shade50,
                            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}