import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import halaman-halaman yang dibutuhkan
import 'package:tugas_kelompok/features/insightmind/presentation/pages/home_page.dart';
import 'package:tugas_kelompok/features/insightmind/presentation/pages/login_page.dart';
import 'package:tugas_kelompok/features/insightmind/presentation/providers/auth_provider.dart';

class InsightMindApp extends ConsumerWidget {
  const InsightMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau status login user secara Realtime (Firebase Auth)
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'InsightMind',
      debugShowCheckedModeBanner: false,
      
      // --- TEMA (Sesuai Kode Anda) ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        useMaterial3: true,
      ),
      
      // --- LOGIKA PEMISAH HALAMAN (AUTH WRAPPER) ---
      home: authState.when(
        data: (user) {
          // Jika user != null (Sudah Login) -> Masuk ke HomePage
          if (user != null) {
            return const HomePage(); 
          } 
          // Jika user == null (Belum Login) -> Masuk ke LoginPage
          else {
            return const LoginPage();
          }
        },
        // Tampilkan loading saat cek status login
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        // Tampilkan error jika terjadi kesalahan koneksi auth
        error: (e, stack) => Scaffold(
          body: Center(child: Text('Error Auth: $e')),
        ),
      ),
    );
  }
}