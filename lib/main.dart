import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/app.dart';
import 'features/insightmind/data/local/screening_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  await Hive.initFlutter();

  // Registrasi adapter untuk model ScreeningRecord
  Hive.registerAdapter(ScreeningRecordAdapter());

  // Membuka box untuk menyimpan riwayat screening
  await Hive.openBox<ScreeningRecord>('screening_records');

  // Membuka box untuk menyimpan jawaban sederhana (list<int>)
  await Hive.openBox('insightmind_answers');

  // Menjalankan aplikasi dengan Riverpod
  runApp(const ProviderScope(child: InsightMindApp()));
}
