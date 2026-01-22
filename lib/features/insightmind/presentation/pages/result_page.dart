import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Auth untuk ambil UID
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/score_provider.dart';
import '../providers/history_providers.dart';
import '../providers/questionnaire_provider.dart'; // PENTING: Untuk reset kuesioner

// Extension untuk menentukan level risiko
extension RiskResultExtensions on RiskResult {
  String get riskLevel {
    final s = score;
    if (s >= 15) return 'Tinggi';
    if (s >= 8) return 'Sedang';
    return 'Rendah';
  }
}

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  // Status untuk loading
  bool _isSaving = true;
  String _saveStatus = "Menyimpan hasil...";

  final Color bgPurple = const Color(0xFF6C5CE7);
  final Color accentPink = const Color(0xFFFF7675);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textDark = const Color(0xFF2D3436);

  @override
  void initState() {
    super.initState();
    // Jalankan simpan data segera setelah halaman dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveDataToHive();
    });
  }

  Future<void> _saveDataToHive() async {
    final result = ref.read(resultProvider);
    final answers = ref.read(answersProvider);

    // 2. AMBIL USER ID DARI FIREBASE
    // Ini penting agar data screening "tertempel" ke akun user tertentu
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "ANONYMOUS"; 
    
    try {
      print("💾 START: Mencoba menyimpan Skor ${result.score} untuk User: $userId...");

      // 3. Gabungkan UID dan Jawaban ke dalam catatan
      // Format: "UID:[xxx] | JAWABAN:[1,0,2...]"
      final noteContent = "UID:$userId | JAWABAN:${answers.join(', ')}";

      // 4. Panggil Repository (Simpan ke DB Lokal Hive)
      await ref.read(historyRepositoryProvider).addRecord(
            score: result.score,
            riskLevel: result.riskLevel,
            note: noteContent, // Simpan string gabungan tadi
          );

      // 5. Refresh Provider agar halaman History & Dashboard update otomatis
      // Menggunakan .notifier karena historyListProvider adalah StateNotifierProvider
      ref.read(historyListProvider.notifier).refresh();

      print("✅ SUCCESS: Data tersimpan!");

      // 6. Update UI
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveStatus = "Data tersimpan otomatis.";
        });
      }
    } catch (e) {
      print("❌ ERROR: Gagal menyimpan - $e");
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveStatus = "Gagal menyimpan data.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(resultProvider);

    String recommendation;
    Color statusColor;
    IconData statusIcon;

    switch (result.riskLevel) {
      case 'Tinggi':
        recommendation =
            'Pertimbangkan berbicara dengan konselor. Kurangi beban dan istirahat cukup.';
        statusColor = const Color(0xFFE17055);
        statusIcon = Icons.warning_rounded;
        break;
      case 'Sedang':
        recommendation =
            'Lakukan relaksasi rutin, olahraga ringan, dan evaluasi beban harian.';
        statusColor = const Color(0xFFFDCB6E);
        statusIcon = Icons.info_rounded;
        break;
      default:
        recommendation =
            'Pertahankan kebiasaan baik. Jaga pola tidur dan makan.';
        statusColor = const Color(0xFF00B894);
        statusIcon = Icons.check_circle_rounded;
    }

    return Scaffold(
      backgroundColor: bgPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        title: const Text(
          'Hasil Screening',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- STATUS BAR (LOADING / SUCCESS) ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _isSaving ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isSaving ? Colors.orange : Colors.green, 
                  width: 1
                )
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSaving) 
                    const SizedBox(
                      width: 12, height: 12, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  else 
                    const Icon(Icons.check, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _saveStatus,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            // --------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: bgPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.psychology_alt, size: 50, color: bgPurple),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'SKOR ANDA',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '${result.score}',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Risiko ${result.riskLevel}',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    recommendation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Tombol Kembali (Hanya aktif jika sudah selesai menyimpan)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving 
                          ? null // Disable tombol saat loading
                          : () {
                              // Reset state kuesioner sebelum kembali
                              ref.read(questionnaireProvider.notifier).reset();
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _isSaving ? 'Tunggu Sebentar...' : 'Kembali ke Menu',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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