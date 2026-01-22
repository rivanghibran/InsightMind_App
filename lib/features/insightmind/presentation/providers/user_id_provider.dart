import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Provider ini bertugas mengecek apakah HP ini sudah punya ID.
// Jika belum, dia akan membuatnya (Generate UUID) dan menyimpannya permanen.
final userIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'local_user_id_token';

  // 1. Cek apakah sudah ada ID tersimpan
  if (prefs.containsKey(key)) {
    return prefs.getString(key)!;
  } 
  // 2. Jika belum ada, buat UUID baru dan simpan
  else {
    final newId = const Uuid().v4();
    await prefs.setString(key, newId);
    return newId;
  }
});