import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; // Import paket UUID sesuai referensi logic
import 'screening_record.dart';

class HistoryRepository {
  static const String boxName = 'screening_records';

  // LOGIKA DARI GAMBAR: Lazy Open Box
  Future<Box<ScreeningRecord>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<ScreeningRecord>(boxName);
    }
    return Hive.openBox<ScreeningRecord>(boxName);
  }

  // LOGIKA DARI GAMBAR: Tambah data dengan UUID sebagai Key
  Future<void> addRecord({
    required int score,
    required String riskLevel,
    String? note,
  }) async {
    final box = await _openBox();
    
    // 1. Buat ID unik menggunakan UUID
    final id = const Uuid().v4();
    
    // 2. Buat objek record
    final record = ScreeningRecord(
      id: id,
      timestamp: DateTime.now(),
      score: score,
      riskLevel: riskLevel,
      note: note,
    );

    // 3. PENTING: Simpan dengan key = id (String)
    // Ini sesuai dengan logika gambar agar mudah dihapus per item
    await box.put(id, record);
    
    print("✅ REPO: Data tersimpan dengan Key ID: $id");
  }

  // LOGIKA DARI GAMBAR: Ambil semua data & urutkan
  Future<List<ScreeningRecord>> getAll() async {
    final box = await _openBox();
    
    return box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // LOGIKA DARI GAMBAR: Hapus berdasarkan ID (Key)
  Future<void> deleteById(String id) async {
    final box = await _openBox();
    
    // Menghapus data spesifik berdasarkan Key UUID
    await box.delete(id);
    
    print("🗑️ REPO: Data ID $id berhasil dihapus");
  }

  // Kosongkan semua
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}

