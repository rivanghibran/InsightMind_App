import 'dart:convert'; // PENTING: Untuk menangani format data JSON
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Pastikan import provider sesuai struktur folder Anda
import '../providers/history_providers.dart';

// --- PALET WARNA ---
const Color _bgPurple = Color(0xFF6C5CE7);
const Color _cardWhite = Color(0xFFFFFFFF);
const Color _textDark = Color(0xFF2D3436);
const Color _bgLight = Color(0xFFF3F0FF);
const Color _accentPink = Color(0xFFFF7675);

class HistoryListPage extends ConsumerWidget {
  const HistoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      backgroundColor: _bgPurple,
      appBar: AppBar(
        title: const Text(
          'Riwayat Lengkap',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: historyAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: _bgPurple)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (records) {
            if (records.isEmpty) {
              return _buildEmptyState();
            }

            // Urutkan dari yang terbaru
            final sortedRecords = List.from(records)
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: sortedRecords.length,
              itemBuilder: (context, index) {
                final record = sortedRecords[index];
                return _HistoryItemCard(record: record);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada riwayat",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final dynamic record;
  const _HistoryItemCard({required this.record});

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Tinggi':
        return const Color(0xFFE17055);
      case 'Sedang':
        return const Color(0xFFFDCB6E);
      default:
        return const Color(0xFF00B894);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(record.timestamp);
    final timeStr = DateFormat('HH:mm').format(record.timestamp);
    final riskColor = _getRiskColor(record.riskLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => _HistoryDetailSheet(record: record),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 50,
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Skor: ${record.score} (${record.riskLevel})",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            "$dateStr • $timeStr",
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: _bgLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, color: _bgPurple),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- MODAL SHEET DETAIL JAWABAN (VERSI LIST SEDERHANA) ---
class _HistoryDetailSheet extends StatelessWidget {
  final dynamic record;
  const _HistoryDetailSheet({required this.record});

  // Helper parsing tetap diperlukan agar data aman
  Map<String, dynamic> _parseAnswers(dynamic rawData) {
    try {
      if (rawData == null) return {};
      var data = rawData;
      
      // Handle String (e.g. "1, 2, 3")
      if (data is String) {
        if (data.contains(',') && !data.trim().startsWith('{')) {
           final List<String> items = data.split(',');
           Map<String, dynamic> mapResult = {};
           for (int i = 0; i < items.length; i++) {
             mapResult['${i + 1}'] = items[i].trim();
           }
           return mapResult;
        }
        try {
          data = jsonDecode(data);
        } catch (e) {
          return {'Catatan': data};
        }
      }
      
      // Handle List
      if (data is List) {
        Map<String, dynamic> mapResult = {};
        for (int i = 0; i < data.length; i++) {
          mapResult['${i + 1}'] = data[i].toString();
        }
        return mapResult;
      }
      
      // Handle Map
      if (data is Map) {
        return data.map((key, value) {
          String newKey = key.toString();
          if (newKey.toLowerCase().contains('pertanyaan')) {
             newKey = newKey.replaceAll(RegExp(r'[^0-9]'), '');
          }
          return MapEntry(newKey, value.toString());
        });
      }
      return {'Info': 'Format data tidak dikenali'};
    } catch (e) {
      return {'Error': 'Gagal memuat'};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Coba akses note dulu, fallback ke answers
    dynamic rawData;
    try { rawData = record.note; } catch (e) {
      try { rawData = record.answers; } catch (e) { rawData = null; }
    }

    final Map<String, dynamic> answers = _parseAnswers(rawData);

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detail Hasil",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _accentPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Skor: ${record.score}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // LIST JAWABAN (SIMPLE LIST)
          Expanded(
            child: answers.isEmpty
                ? const Center(child: Text("Tidak ada detail jawaban"))
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: answers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final key = answers.keys.elementAt(index);
                      final value = answers[key];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            // Nomor Lingkaran Kecil
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: _bgLight,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                key, // No urut
                                style: const TextStyle(
                                  color: _bgPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Nilai Jawaban
                            Text(
                              value.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Tombol Tutup
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bgPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Tutup"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}