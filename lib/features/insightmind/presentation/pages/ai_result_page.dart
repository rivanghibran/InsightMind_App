// WEEK 7 - UI Prediksi AI Modern
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kelompok/features/insightmind/data/models/feature_vector.dart';
import '../providers/ai_provider.dart';

class AIResultPage extends ConsumerWidget {
  final FeatureVector fv;

  const AIResultPage({
    super.key,
    required this.fv,
  });

  // Palet Warna
  final Color bgPurple = const Color(0xFF6C5CE7);
  final Color accentPink = const Color(0xFFFF7675);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textDark = const Color(0xFF2D3436);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(aiResultProvider(fv));

    final String level = result['riskLevel'] ?? 'Unknown';
    final double weighted = result['weightedScore'] ?? 0.0;
    final double confidence = result['confidence'] ?? 0.0;

    // Tentukan Warna & Icon berdasarkan Level Risiko
    Color statusColor;
    IconData statusIcon;
    String message;

    switch (level) {
      case 'Tinggi':
        statusColor = const Color(0xFFE17055); // Merah Bata
        statusIcon = Icons.warning_amber_rounded;
        message = "Terdeteksi indikasi stres tinggi. Segera cari bantuan profesional.";
        break;
      case 'Sedang':
        statusColor = const Color(0xFFFDCB6E); // Kuning/Orange
        statusIcon = Icons.info_outline_rounded;
        message = "Perlu perhatian. Coba kurangi beban kerja dan istirahat.";
        break;
      default: // Rendah
        statusColor = const Color(0xFF00B894); // Hijau Teal
        statusIcon = Icons.verified_user_outlined;
        message = "Kondisi mental stabil. Pertahankan gaya hidup sehat!";
    }

    return Scaffold(
      backgroundColor: bgPurple,
      appBar: AppBar(
        title: const Text(
          "Hasil Prediksi AI",
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
            const Text(
              "Analisa Selesai!",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),

            // === KARTU HASIL ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Icon Status Besar
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      size: 64,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Teks Level Risiko
                  const Text(
                    "TINGKAT RISIKO",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // 3. Grid Statistik (Score & Confidence)
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: "AI Score",
                          value: weighted.toStringAsFixed(2),
                          color: bgPurple,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _StatItem(
                          label: "Confidence",
                          value: "${(confidence * 100).toStringAsFixed(0)}%",
                          color: accentPink,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 4. Pesan Rekomendasi
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textDark.withOpacity(0.8),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 5. Tombol Kembali
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bgPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Kembali ke Menu",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

// Helper Widget untuk Item Statistik
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}