import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'screening_record.dart';

class HistoryRepository {
  static const String boxName = 'screening_records';

  // Buka box jika belum terbuka (lazy-open)
  Future<Box<ScreeningRecord>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<ScreeningRecord>(boxName);
    }
    return Hive.openBox<ScreeningRecord>(boxName);
    // Catatan: bisa ditambah enkripsi menggunakan HiveAesCipher jika diperlukan
  }

  // Tambah satu record riwayat saat user melihat hasil screening
  Future<void> addRecord({
    required int score,
    required String riskLevel,
    String? note,
  }) async {
    final box = await _openBox();
    final id = const Uuid().v4(); // membuat ID unik

    final record = ScreeningRecord(
      id: id,
      timestamp: DateTime.now(),
      score: score,
      riskLevel: riskLevel,
      note: note,
    );

    await box.put(id, record);
  }

  // Ambil semua riwayat dan urutkan dari terbaru
  Future<List<ScreeningRecord>> getAll() async {
    final box = await _openBox();
    return box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Hapus satu riwayat berdasarkan id
  Future<void> deleteById(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  // Hapus seluruh riwayat
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
