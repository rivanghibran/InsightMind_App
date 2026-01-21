// WEEK 7: Provider inferensi AI
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kelompok/features/insightmind/domain/usecases/predict_risk_ai.dart';
import 'package:tugas_kelompok/features/insightmind/data/models/feature_vector.dart';


/// Provider untuk instance AI predictor.
final aiPredictorProvider = Provider<PredictRiskAI>((ref) {
  return PredictRiskAI();
});

/// Provider untuk menghasilkan hasil inferensi AI berdasarkan FeatureVector.
final aiResultProvider =
    Provider.family<Map<String, dynamic>, FeatureVector>((ref, fv) {
  final predictor = ref.watch(aiPredictorProvider);
  return predictor.predict(fv);
});
