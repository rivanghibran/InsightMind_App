// WEEK 7: PredictRiskAI - Rule-based AI sederhana
import 'package:tugas_kelompok/features/insightmind/data/models/feature_vector.dart';

class PredictRiskAI {
  /// Menghitung prediksi tingkat risiko berdasarkan kombinasi:
  /// - skor screening
  /// - variansi accelerometer
  /// - variansi PPG
  ///
  /// Menghasilkan: weightedScore, riskLevel, dan confidence.
  Map<String, dynamic> predict(FeatureVector f) {
    // Weighted score
    final double weightedScore = 
        (f.screeningScore * 0.6) +
        ((f.activityVar * 10) * 0.2) +
        ((f.ppgVar * 1000) * 0.2);

    // Penentuan level risiko
    late final String level;

    if (weightedScore > 25) {
      level = 'Tinggi';
    } else if (weightedScore > 12) {
      level = 'Sedang';
    } else {
      level = 'Rendah';
    }

    // Confidence sederhana (range 0.3–0.95)
    final double confidence = (weightedScore / 30).clamp(0.3, 0.95);

    return {
      'weightedScore': weightedScore,
      'riskLevel': level,
      'confidence': confidence,
    };
  }
}
