// WEEK 7: Feature Vector untuk AI InsightMind

/// Representasi fitur yang akan dipakai model AI.
/// Berisi gabungan data dari screening, accelerometer, dan PPG.
class FeatureVector {
  /// Skor total dari kuisioner screening.
  final double screeningScore;

  /// Rata-rata magnitude accelerometer.
  final double activityMean;

  /// Variansi magnitude accelerometer, indikasi tingkat stres/ketegangan.
  final double activityVar;

  /// Rata-rata sinyal PPG (dari kamera).
  final double ppgMean;

  /// Variansi sinyal PPG.
  final double ppgVar;

  const FeatureVector({
    required this.screeningScore,
    required this.activityMean,
    required this.activityVar,
    required this.ppgMean,
    required this.ppgVar,
  });

  @override
  String toString() {
    return 'FeatureVector('
        'screeningScore: $screeningScore, '
        'activityMean: $activityMean, '
        'activityVar: $activityVar, '
        'ppgMean: $ppgMean, '
        'ppgVar: $ppgVar)';
  }
}
