// WEEK6 + WEEK7: Integrasi Sensor → FeatureVector → AI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kelompok/features/insightmind/data/models/feature_vector.dart';

import '../providers/sensors_provider.dart';
import '../providers/ppg_provider.dart';
import '../providers/score_provider.dart';
import 'ai_result_page.dart';

class BiometricPage extends ConsumerWidget {
  const BiometricPage({super.key});

  // Palet Warna (Brain Games Theme)
  final Color bgPurple = const Color(0xFF6C5CE7);
  final Color accentPink = const Color(0xFFFF7675);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textDark = const Color(0xFF2D3436);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accelFeat = ref.watch(accelFeatureProvider);
    final ppg = ref.watch(ppgProvider);
    final score = ref.watch(scoreProvider);

    return Scaffold(
      backgroundColor: bgPurple,
      appBar: AppBar(
        title: const Text(
          "Sensor Lab",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Biometric Data",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),

          // === KARTU 1: ACCELEROMETER (Motion) ===
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_run,
                          color: Colors.blueAccent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Motion Analysis",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          "Accelerometer Sensor",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Data Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: "Mean",
                        value: accelFeat.mean.toStringAsFixed(4),
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        label: "Variance",
                        value: accelFeat.variance.toStringAsFixed(4),
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // === KARTU 2: PPG CAMERA (Vision) ===
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentPink.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.monitor_heart,
                              color: accentPink, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Heart Vision",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            Text(
                              "Camera PPG",
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ppg.capturing
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ppg.capturing ? "Active" : "Idle",
                        style: TextStyle(
                          color: ppg.capturing ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Data Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: "Samples",
                        value: "${ppg.samples.length}",
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        label: "Mean Y",
                        value: ppg.mean.toStringAsFixed(4),
                        color: accentPink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _StatBox(
                    label: "Variance Y",
                    value: ppg.variance.toStringAsFixed(6),
                    color: Colors.purple,
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol Start/Stop Capture
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final notifier = ref.read(ppgProvider.notifier);
                      ppg.capturing
                          ? notifier.stopCapture()
                          : notifier.startCapture();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ppg.capturing ? textDark : accentPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                        ppg.capturing ? Icons.stop_circle : Icons.play_circle),
                    label: Text(
                      ppg.capturing ? "Hentikan Scan" : "Mulai Scan PPG",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // === TOMBOL UTAMA: AI PREDICTION ===
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                if (ppg.samples.length < 30) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          "Data kurang! Ambil minimal 30 sampel PPG."),
                      backgroundColor: accentPink,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final fv = FeatureVector(
                  screeningScore: score.toDouble(),
                  activityMean: accelFeat.mean,
                  activityVar: accelFeat.variance,
                  ppgMean: ppg.mean,
                  ppgVar: ppg.variance,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIResultPage(fv: fv),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: bgPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology, color: bgPurple),
                  const SizedBox(width: 12),
                  const Text(
                    "Hitung Prediksi AI",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Helper Widget untuk Kotak Statistik Kecil
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}