import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tflite_demo/speech_service.dart';
import 'package:flutter_tflite_demo/tensor_flow_service.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final TensorFlowService tensorFlowService = TensorFlowService();
  final SpeechService speechService = SpeechService();
  await tensorFlowService.loadModel();
  runApp(MyApp(
    tensorFlowService: tensorFlowService,
    speechService: speechService,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key,
      required this.tensorFlowService,
      required this.speechService});

  final TensorFlowService tensorFlowService;
  final SpeechService speechService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'TensorFlow Demo',
        tensorFlowService: tensorFlowService,
        speechService: speechService,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.tensorFlowService,
    required this.speechService,
  });

  final String title;
  final SpeechService speechService;
  final TensorFlowService tensorFlowService;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _modelStatus = 'Click to run model';
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _runModel() async {
    if (_image == null) {
      _modelStatus = 'No image selected';
      setState(() {});
      debugPrint('No image selected');
      return;
    }
    try {
      // var input = List.generate(
      //     1, //Numero de Imagines
      //     (i) => List.generate(
      //         224, // Altura de Imagen
      //         (j) => List.generate(
      //             224, // Ancho de Imagen
      //             (k) => List.generate(
      //                 3, // RGB
      //                 (l) => 0.5))));

      var result = await widget.tensorFlowService.runModel(_image!);
      _modelStatus = result != null
          ? 'Model run successfully: $result results'
          : 'Model run failed';
    } catch (e) {
      _modelStatus = 'Error running model: $e';
    } finally {
      setState(() {
        debugPrint(_modelStatus);
      });
    }
  }

  void _toogleListening() async {
    if (widget.speechService.isListening) {
      widget.speechService.stopListening();
    } else {
      await widget.speechService.startListening();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Recognition: ${widget.speechService.recognizedText}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
              ElevatedButton(
                onPressed: _toogleListening,
                child: Text(widget.speechService.isListening
                    ? 'Stop Listening'
                    : 'Start Listening'),
              ),
              Divider(),
              SizedBox(height: 20),
              Text(
                _modelStatus,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              (_image != null)
                  ? Image.file(
                      _image!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                  : const Text('No image selected'),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _runModel, child: const Text('Run Model')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runModel,
        tooltip: 'Run Model',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
