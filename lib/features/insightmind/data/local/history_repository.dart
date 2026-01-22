import 'package:firebase_auth/firebase_auth.dart'; // 1. Wajib Import Auth
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'screening_record.dart';

class HistoryRepository {
  static const String boxName = 'screening_records';

  Future<Box<ScreeningRecord>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<ScreeningRecord>(boxName);
    }
    return Hive.openBox<ScreeningRecord>(boxName);
  }

  // --- MODIFIKASI 1: SIMPAN DATA DENGAN UID ---
  Future<void> addRecord({
    required int score,
    required String riskLevel,
    String? note,
  }) async {
    final box = await _openBox();
    
    // 1. Ambil User ID dari Firebase
    final user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? "ANONYMOUS";

    // 2. Generate ID Unik untuk data ini
    final id = const Uuid().v4();

    // 3. Gabungkan UID ke dalam 'note' agar data ini "milik" user tersebut
    // Format: "UID:xxxxx|CatatanAsli"
    final String securedNote = "UID:$uid|${note ?? ''}";

    final record = ScreeningRecord(
      id: id,
      timestamp: DateTime.now(),
      score: score,
      riskLevel: riskLevel,
      note: securedNote, // Simpan note yang sudah ditempel UID
    );

    await box.put(id, record);
    print("✅ REPO: Data tersimpan untuk User: $uid (Key: $id)");
  }

  // --- MODIFIKASI 2: AMBIL DATA HANYA MILIK USER LOGIN ---
  Future<List<ScreeningRecord>> getAll() async {
    final box = await _openBox();
    
    // 1. Cek siapa yang login
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return []; // Jika tidak login, jangan kasih data apa-apa
    }
    final String uid = user.uid;

    // 2. Ambil semua data dari kotak
    final allRecords = box.values.toList();

    // 3. FILTER: Hanya ambil data yang note-nya mengandung UID user ini
    final userRecords = allRecords.where((record) {
      final noteContent = record.note ?? "";
      return noteContent.contains("UID:$uid");
    }).toList();

    // 4. Urutkan dari yang terbaru
    userRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return userRecords;
  }

  // Hapus berdasarkan ID (Key)
  Future<void> deleteById(String id) async {
    final box = await _openBox();
    await box.delete(id); 
    print("🗑️ REPO: Data ID $id berhasil dihapus");
  }

  // Kosongkan semua (Hanya data lokal, hati-hati menggunakan ini)
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}

