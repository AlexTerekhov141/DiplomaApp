import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'TFliteRepository.dart';

class TFliteRepositoryImpl implements TFliteRepository {
  TFliteRepositoryImpl({
    this.modelAssetPath = 'assets/ml/model_fp16.tflite',
    this.labelsAssetPath = 'assets/ml/labels.json',
    this.configAssetPath = 'assets/ml/model_config.json',
  });

  final String modelAssetPath;
  final String labelsAssetPath;
  final String configAssetPath;

  Interpreter? _interpreter;
  List<String> _labels = <String>[];
  _ModelConfig _config = const _ModelConfig();
  bool _isInitialized = false;
  late TensorType _inputType;
  late TensorType _outputType;
  late int _inputHeight;
  late int _inputWidth;
  double _inputScale = 1.0;
  int _inputZeroPoint = 0;
  double _outputScale = 1.0;
  int _outputZeroPoint = 0;

  @override
  Future<void> ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    final String configRaw = await rootBundle.loadString(configAssetPath);
    _config = _ModelConfig.fromJson(
      jsonDecode(configRaw) as Map<String, dynamic>,
    );

    final String labelsRaw = await rootBundle.loadString(labelsAssetPath);
    final List<dynamic> labelsJson = jsonDecode(labelsRaw) as List<dynamic>;
    _labels = labelsJson.whereType<String>().toList();
    if (_labels.isEmpty) {
      throw StateError('labels.json is empty');
    }

    final InterpreterOptions options = InterpreterOptions();
    if (!kIsWeb && Platform.isAndroid) {
      options.useNnApiForAndroid = false;
    }
    _interpreter = await Interpreter.fromAsset(modelAssetPath, options: options);

    final Tensor inputTensor = _interpreter!.getInputTensor(0);
    final Tensor outputTensor = _interpreter!.getOutputTensor(0);

    _inputType = inputTensor.type;
    _outputType = outputTensor.type;

    final List<int> inputShape = inputTensor.shape;
    _inputHeight = inputShape.length >= 3 ? inputShape[1] : _config.height;
    _inputWidth = inputShape.length >= 3 ? inputShape[2] : _config.width;

    _inputScale = inputTensor.params.scale == 0 ? 1.0 : inputTensor.params.scale;
    _inputZeroPoint = inputTensor.params.zeroPoint;
    _outputScale = outputTensor.params.scale == 0 ? 1.0 : outputTensor.params.scale;
    _outputZeroPoint = outputTensor.params.zeroPoint;

    if (kDebugMode) {
      debugPrint(
        'TFLite init: inputType=$_inputType outputType=$_outputType '
        'inputShape=${inputTensor.shape} outputShape=${outputTensor.shape} '
        'inputQ=($_inputScale,$_inputZeroPoint) outputQ=($_outputScale,$_outputZeroPoint)',
      );
    }
    _isInitialized = true;
  }

  @override
  Future<TFlitePrediction> classifyImageBytes(Uint8List imageBytes) async {
    await ensureInitialized();

    final img.Image? decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw ArgumentError('Unable to decode image bytes');
    }

    final img.Image rgb = decoded.numChannels == 3
        ? decoded
        : img.copyResize(decoded, width: decoded.width, height: decoded.height);
    final img.Image resized = img.copyResize(
      rgb,
      width: _inputWidth,
      height: _inputHeight,
      interpolation: img.Interpolation.linear,
    );

    final Object input = _buildInput(resized);
    final int outputSize = _interpreter!.getOutputTensor(0).shape.last;
    final Object output = _createOutputBuffer(outputSize);

    _interpreter!.run(input, output);

    final List<double> probs = _extractProbabilities(output);
    int bestIndex = 0;
    double bestValue = probs.first;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > bestValue) {
        bestValue = probs[i];
        bestIndex = i;
      }
    }

    final String label = bestIndex < _labels.length
        ? _labels[bestIndex]
        : 'unknown';

    return TFlitePrediction(
      label: label,
      confidence: bestValue,
      classIndex: bestIndex,
      probabilities: probs,
    );
  }

  double _normalize(double value, int channelIndex) {
    final double scaled = value / _config.scale;
    final double mean = _config.mean[channelIndex];
    final double std = _config.std[channelIndex] == 0
        ? 1.0
        : _config.std[channelIndex];
    return (scaled - mean) / std;
  }

  Object _buildInput(img.Image resized) {
    switch (_inputType) {
      case TensorType.float32:
        return <List<List<List<double>>>>[
          List<List<List<double>>>.generate(
            _inputHeight,
            (int y) => List<List<double>>.generate(
              _inputWidth,
              (int x) {
                final img.Pixel pixel = resized.getPixel(x, y);
                final double rf = _normalize(pixel.r.toDouble(), 0);
                final double gf = _normalize(pixel.g.toDouble(), 1);
                final double bf = _normalize(pixel.b.toDouble(), 2);
                return <double>[rf, gf, bf];
              },
            ),
          ),
        ];
      case TensorType.uint8:
        return <List<List<List<int>>>>[
          List<List<List<int>>>.generate(
            _inputHeight,
            (int y) => List<List<int>>.generate(
              _inputWidth,
              (int x) {
                final img.Pixel pixel = resized.getPixel(x, y);
                return <int>[
                  _quantizeToUInt8(_normalize(pixel.r.toDouble(), 0)),
                  _quantizeToUInt8(_normalize(pixel.g.toDouble(), 1)),
                  _quantizeToUInt8(_normalize(pixel.b.toDouble(), 2)),
                ];
              },
            ),
          ),
        ];
      case TensorType.int8:
        return <List<List<List<int>>>>[
          List<List<List<int>>>.generate(
            _inputHeight,
            (int y) => List<List<int>>.generate(
              _inputWidth,
              (int x) {
                final img.Pixel pixel = resized.getPixel(x, y);
                return <int>[
                  _quantizeToInt8(_normalize(pixel.r.toDouble(), 0)),
                  _quantizeToInt8(_normalize(pixel.g.toDouble(), 1)),
                  _quantizeToInt8(_normalize(pixel.b.toDouble(), 2)),
                ];
              },
            ),
          ),
        ];
      default:
        throw UnsupportedError('Unsupported input type: $_inputType');
    }
  }

  Object _createOutputBuffer(int outputSize) {
    switch (_outputType) {
      case TensorType.float32:
        return <List<double>>[List<double>.filled(outputSize, 0.0)];
      case TensorType.uint8:
      case TensorType.int8:
        return <List<int>>[List<int>.filled(outputSize, 0)];
      default:
        throw UnsupportedError('Unsupported output type: $_outputType');
    }
  }

  List<double> _extractProbabilities(Object output) {
    if (output is! List || output.isEmpty || output.first is! List) {
      throw StateError('Unexpected output format from TFLite interpreter');
    }
    final List<dynamic> raw = output.first as List<dynamic>;

    if (_outputType == TensorType.float32) {
      return raw.map((dynamic e) => (e as num).toDouble()).toList();
    }

    return raw.map((dynamic e) {
      final double q = (e as num).toDouble();
      return (q - _outputZeroPoint) * _outputScale;
    }).toList();
  }

  int _quantizeToUInt8(double value) {
    final int q = (value / _inputScale + _inputZeroPoint).round();
    if (q < 0) {
      return 0;
    }
    if (q > 255) {
      return 255;
    }
    return q;
  }

  int _quantizeToInt8(double value) {
    final int q = (value / _inputScale + _inputZeroPoint).round();
    if (q < -128) {
      return -128;
    }
    if (q > 127) {
      return 127;
    }
    return q;
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

class _ModelConfig {
  const _ModelConfig({
    this.width = 224,
    this.height = 224,
    this.scale = 255.0,
    this.mean = const <double>[0.0, 0.0, 0.0],
    this.std = const <double>[1.0, 1.0, 1.0],
  });

  factory _ModelConfig.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> input =
        (json['input'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<String, dynamic> preprocess =
        (json['preprocess'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    List<double> parseList(dynamic raw, List<double> fallback) {
      if (raw is List<dynamic> && raw.length >= 3) {
        final List<double> parsed =
            raw.map((dynamic e) => (e as num).toDouble()).toList();
        return parsed;
      }
      return fallback;
    }

    return _ModelConfig(
      width: (input['width'] as num?)?.toInt() ?? 224,
      height: (input['height'] as num?)?.toInt() ?? 224,
      scale: (preprocess['scale'] as num?)?.toDouble() ?? 255.0,
      mean: parseList(preprocess['mean'], const <double>[0.0, 0.0, 0.0]),
      std: parseList(preprocess['std'], const <double>[1.0, 1.0, 1.0]),
    );
  }

  final int width;
  final int height;
  final double scale;
  final List<double> mean;
  final List<double> std;
}
