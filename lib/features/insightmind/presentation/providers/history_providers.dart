import 'package:firebase_auth/firebase_auth.dart'; // 1. Wajib Import Auth
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'screening_record.dart';

/// 1. Provider untuk mengakses repository
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

/// 2. Notifier: Mengelola Logika State (Load & Refresh)
class HistoryListNotifier extends StateNotifier<AsyncValue<List<ScreeningRecord>>> {
  final HistoryRepository _repository;

  HistoryListNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Otomatis muat data saat aplikasi dibuka
    loadData();
  }

  // Fungsi ambil data dari Hive
  Future<void> loadData() async {
    try {
      final data = await _repository.getAll();
      
      if (mounted) {
        state = AsyncValue.data(data);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  // Fungsi ini yang dipanggil oleh ResultPage: ref.read(...).refresh()
  Future<void> refresh() async {
    // Set loading agar UI berkedip sebentar (indikator update)
    state = const AsyncValue.loading();
    await loadData();
  }
}

/// 3. Provider Utama (StateNotifierProvider)
/// Tipe ini MEMILIKI .notifier, sehingga error di ResultPage akan hilang
final historyListProvider = StateNotifierProvider<HistoryListNotifier, AsyncValue<List<ScreeningRecord>>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return HistoryListNotifier(repo);
});