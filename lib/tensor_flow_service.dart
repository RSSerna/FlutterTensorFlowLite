import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
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

  Future<List<double>?> runModel(File imageFile) async {
    if (_interpreter == null) {
      debugPrint('Interpreter is not initialized');
      return null;
    }

    List<List<List<List<double>>>> input = List.generate(
        1, //Numero de Imagines
        (i) => List.generate(
            224, // Altura de Imagen
            (j) => List.generate(
                224, // Ancho de Imagen
                (k) => List.generate(
                    3, // RGB
                    (l) => 0.0))));

    img.Image? inputImage = img.decodeImage(imageFile.readAsBytesSync());
    img.Image resizedImage = img.copyResize(inputImage!,
        width: 224, height: 224); // Resize to match model input size

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);
        // Normalize pixel values to [0, 1]
        // resizedImage.setPixel(
        //     x, y, img.getColor(pixel.r / 255, pixel.g / 255, pixel.b / 255));
        input[0][y][x][0] = pixel.r / 255.0; // Red
        input[0][y][x][1] = pixel.g / 255.0; // Green
        input[0][y][x][2] = pixel.b / 255.0; // Blue
      }
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
