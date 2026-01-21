import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/score_provider.dart';
import 'screening_page.dart'; // Alur Minggu 2–5
import 'biometric_page.dart'; // Alur Minggu 6–8
import 'dashboard_page.dart'; // Analitik dashboard

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  // Palet Warna berdasarkan Referensi Gambar (Brain Games UI)
  final Color bgPurple = const Color(0xFF6C5CE7); // Ungu vibrant
  final Color accentPink = const Color(0xFFFF7675); // Pink/Salmon
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textDark = const Color(0xFF2D3436);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);

    return Scaffold(
      backgroundColor: bgPurple, // Latar belakang ungu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'InsightMind',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          // Menampilkan Skor seperti Coin/Gem di Game
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$score', // Skor dinamis
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        children: [
          const SizedBox(height: 10),
          const Text(
            "Hello, User!",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Discover your mental state now.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // ===============================
          // Kartu 1: Screening Kuisioner (M2–M5)
          // ===============================
          // Didesain seperti kartu "Daily Brain Boost"
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ikon/Ilustrasi (Menggunakan Icon karena tidak ada aset gambar)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb,
                          color: Colors.orange, size: 32),
                    ),
                    // Badge Indikasi
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: bgPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Self Assessment",
                        style: TextStyle(
                            color: bgPurple, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Screening Awal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jawab pertanyaan sederhana untuk cek kesehatan mentalmu.',
                  style: TextStyle(color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 20),

                // Tombol Utama (Pink)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScreeningPage(),
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
                      elevation: 0,
                    ),
                    child: const Text(
                      'Mulai Screening',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tombol Sekunder (Dashboard) - Dibuat Outline agar tidak rebutan fokus
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.bar_chart_rounded, color: bgPurple),
                    label: Text(
                      'Lihat Dashboard',
                      style: TextStyle(color: bgPurple),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: bgPurple.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Advanced Features",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // ===============================
          // Kartu 2: Sensor & Biometrik (M6–M8)
          // ===============================
          // Didesain seperti list item pada gambar referensi
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BiometricPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  // Icon Box
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.sensors,
                        color: Colors.blueAccent, size: 30),
                  ),
                  const SizedBox(width: 16),
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sensor & AI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Analisa biometrik wajah & gerakan.',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}