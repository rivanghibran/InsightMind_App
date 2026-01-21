import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart'; // Pastikan import ini mengarah ke file HomePage Anda

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  
  // Palet Warna (Sesuai Tema)
  final Color bgPurple = const Color(0xFF6C5CE7);
  final Color accentPink = const Color(0xFFFF7675);

  @override
  void initState() {
    super.initState();
    // Timer: Tunggu 3 detik, lalu pindah ke HomePage
    Timer(const Duration(seconds: 3), () {
      // Menggunakan pushReplacement agar user tidak bisa kembali ke halaman loading
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPurple,
      body: Stack(
        children: [
          // Center Content (Logo & Text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon dengan Animasi Skala Kecil (Opsional)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_alt, // Ikon Otak
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Judul Aplikasi
                const Text(
                  'InsightMind',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check your mental health, anytime.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 48),

                // Loading Indicator (Warna Pink)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: accentPink,
                    strokeWidth: 4,
                  ),
                ),
              ],
            ),
          ),

          // Footer Version Text
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                'v1.0.0 • Powered by AI',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}