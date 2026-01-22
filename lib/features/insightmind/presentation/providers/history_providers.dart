import 'package:flutter_riverpod/flutter_riverpod.dart';

// Pastikan path import ini sesuai dengan lokasi file Anda yang sebenarnya
import '../../data/local/history_repository.dart'; 
import '../../data/local/screening_record.dart';

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