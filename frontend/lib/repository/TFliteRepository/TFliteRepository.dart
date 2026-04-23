import 'dart:typed_data';

class TFlitePrediction {
  const TFlitePrediction({
    required this.label,
    required this.confidence,
    required this.classIndex,
    required this.probabilities,
  });

  final String label;
  final double confidence;
  final int classIndex;
  final List<double> probabilities;
}

abstract class TFliteRepository {
  Future<void> ensureInitialized();

  Future<TFlitePrediction> classifyImageBytes(Uint8List imageBytes);

  void dispose();
}
