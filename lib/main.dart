import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/app.dart'; 
import 'features/insightmind/data/local/screening_record.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Hive
  await Hive.initFlutter();

  // 2. Register Adapter (Wajib)
  Hive.registerAdapter(ScreeningRecordAdapter());
  


  runApp(const ProviderScope(child: InsightMindApp()));
}