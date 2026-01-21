import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// [Bagian AnswersNotifier dan Providers lainnya tidak berubah]

final answersProvider =
    StateNotifierProvider<AnswersNotifier, List<int>>((ref) => AnswersNotifier());

class AnswersNotifier extends StateNotifier<List<int>> {
  static const _boxName = 'insightmind_answers';
  static const _key = 'answers';

  AnswersNotifier() : super([]) {
    _init();
  }
// ... [Implementasi AnswersNotifier lainnya]
  Future<void> _init() async {
    try {
      final box = Hive.box(_boxName);
      final stored = box.get(_key);
      if (stored is List) {
        state = stored.map((e) {
          if (e is int) return e;
          return int.tryParse(e.toString()) ?? 0;
        }).toList();
      }
    } catch (_) {
      state = [];
    }
  }

  @override
  set state(List<int> value) {
    super.state = value;
    try {
      Hive.box(_boxName).put(_key, value);
    } catch (_) {}
  }

  void addAnswer(int value) {
    state = [...state, value];
  }

  void clear() {
    state = [];
    try {
      Hive.box(_boxName).delete(_key);
    } catch (_) {}
  }
}

// ----------------------------------------------------------------------
/// Data Riwayat Contoh
/// Digunakan untuk menginisialisasi state jika Hive kosong.
// ----------------------------------------------------------------------
final List<Map<String, dynamic>> _initialHistoryData = [
  {
    'date': DateTime.now().subtract(const Duration(days: 5, hours: 2)).toIso8601String(),
    'answers': [1, 0, 1, 0, 1, 0, 1],
    'score': 4,
    'level': 'Sedang',
  },
  {
    'date': DateTime.now().subtract(const Duration(days: 2, minutes: 30)).toIso8601String(),
    'answers': [3, 3, 3, 3, 3, 3, 3],
    'score': 21,
    'level': 'Tinggi',
  },
  {
    'date': DateTime.now().toIso8601String(), // Riwayat terbaru
    'answers': [0, 0, 0, 1, 0, 0, 0],
    'score': 1,
    'level': 'Rendah',
  },
];


/// ---------- History provider ----------
/// Riwayat disimpan di key 'history' dalam box 'insightmind_answers'
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<Map<String, dynamic>>>(
        (ref) => HistoryNotifier());

class HistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  static const _boxName = 'insightmind_answers';
  static const _key = 'history';

  // 👇 MODIFIKASI: Masukkan data awal jika Hive kosong.
  HistoryNotifier() : super([]) {
    _init();
  }

  void _init() {
    try {
      final box = Hive.box(_boxName);
      final stored = box.get(_key);
      
      if (stored is List && stored.isNotEmpty) {
        // Data ditemukan di Hive, gunakan data tersebut
        state = stored.map<Map<String, dynamic>>((e) {
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return <String, dynamic>{};
        }).toList();
      } else {
        // Data tidak ditemukan di Hive atau kosong, gunakan data contoh
        state = _initialHistoryData; 
        
        // Simpan data contoh ini ke Hive untuk penggunaan selanjutnya
        box.put(_key, state);
      }
    } catch (e) {
      // Jika terjadi kesalahan (misalnya, box belum dibuka), gunakan data contoh
      state = _initialHistoryData; 
    }
  }

  /// Tambah record ke riwayat dan simpan ke Hive.
  void addRecord({
    required DateTime date,
    required List<int> answers,
    required int score,
    required String level,
  }) {
    final record = {
      'date': date.toIso8601String(),
      'answers': answers,
      'score': score,
      'level': level,
    };
    // Tambahkan record baru di awal (agar yang terbaru di atas)
    state = [record, ...state]; 
    try {
      Hive.box(_boxName).put(_key, state);
    } catch (_) {}
  }
// ... [Implementasi deleteAt dan clearAll lainnya]
  /// Hapus record pada indeks tertentu
  void deleteAt(int index) {
    if (index < 0 || index >= state.length) return;
    final newState = [...state]..removeAt(index);
    state = newState;
    try {
      Hive.box(_boxName).put(_key, state);
    } catch (_) {}
  }

  /// Bersihkan seluruh riwayat
  void clearAll() {
    state = [];
    try {
      Hive.box(_boxName).delete(_key);
    } catch (_) {}
  }
}

/// ----------------------
/// Implementasi Lainnya (tidak diubah)
/// ----------------------

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepository();
});

final calculateRiskProvider = Provider<CalculateRiskLevel>((ref) {
  return CalculateRiskLevel();
});

final scoreProvider = Provider<int>((ref) {
  final repo = ref.watch(scoreRepositoryProvider);
  final answers = ref.watch(answersProvider);
  return repo.calculateScore(answers);
});

final resultProvider = Provider<RiskResult>((ref) {
  final score = ref.watch(scoreProvider);
  final usecase = ref.watch(calculateRiskProvider);
  return usecase.execute(score);
});

class ScoreRepository {
  int calculateScore(List<int> answers) {
    if (answers.isEmpty) return 0;
    return answers.fold<int>(0, (sum, item) => sum + item);
  }
}

class RiskResult {
  final int score;
  final String level;

  RiskResult({required this.score, required this.level});

  @override
  String toString() => 'RiskResult(score: $score, level: $level)';
}

class CalculateRiskLevel {
  RiskResult execute(int score) {
    String level;
    if (score <= 3) {
      level = 'Rendah';
    } else if (score <= 6) {
      level = 'Sedang';
    } else {
      level = 'Tinggi';
    }
    return RiskResult(score: score, level: level);
  }
}