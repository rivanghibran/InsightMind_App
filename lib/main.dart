import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- 1. TAMBAHAN PENTING (Import ini)

import 'src/app.dart'; 
import 'features/insightmind/data/local/screening_record.dart'; 
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Init Firebase ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- Init Locale Data (Solusi Error PDF) ---
  // Baris ini WAJIB ada agar format tanggal 'id_ID' (Indonesia) dikenali
  await initializeDateFormatting('id_ID', null); 

  // --- Init Hive Database ---
  await Hive.initFlutter();
  Hive.registerAdapter(ScreeningRecordAdapter());
  await Hive.openBox<ScreeningRecord>('screening_records');

  runApp(const ProviderScope(child: InsightMindApp()));
}