abstract class OfflinePredictionsStorage {
  Future<Map<String, dynamic>?> getPrediction(String assetId);

  Future<Map<String, Map<String, dynamic>>> getPredictionsByIds(
    Iterable<String> assetIds,
  );

  Future<void> upsertPrediction(
    String assetId,
    Map<String, dynamic> prediction,
  );

  Future<void> upsertPredictions(
    Map<String, Map<String, dynamic>> predictions,
  );

  Future<void> deleteMissingAssets(Set<String> existingAssetIds);

  Future<int> countProcessed(String modelVersion);

  Future<void> clear();
}
