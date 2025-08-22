import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorFlowService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/models/mobilenet_v1_1.0_224.tflite');
      debugPrint('Model loaded successfully');
      if (_interpreter != null) {
        debugPrint('Interpreter is not null');
        var inputShape = _interpreter!.getInputTensor(0).shape;
        var outputShape = _interpreter!.getOutputTensor(0).shape;
        debugPrint('Input shape: $inputShape');
        debugPrint('Output shape: $outputShape');
      } else {
        debugPrint('Interpreter is null');
      }
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<List<double>?> runModel(List<List<List<List<double>>>> input) async {
    if (_interpreter == null) {
      debugPrint('Interpreter is not initialized');
      return null;
    }

    var output = List.filled(1 * 1001, 0.0).reshape([1, 1001]);

    try {
      _interpreter!.run(input, output);
      debugPrint('Inference run successfully');
      return output[0];
    } catch (e) {
      debugPrint('Error during inference: $e');
      return null;
    }
  }

  // List<List<List<List<double>>>> input = List.generate(
  //     1, //Numero de Imagines
  //     (i) => List.generate(
  //         224, // Altura de Imagen
  //         (j) => List.generate(
  //             224, // Ancho de Imagen
  //             (k) => List.generate(
  //                 3, // RGB
  //                 (l) => 0.0))));
}
