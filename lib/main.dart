import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tflite_demo/tensor_flow_service.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final TensorFlowService tensorFlowService = TensorFlowService();
  await tensorFlowService.loadModel();
  runApp(MyApp(
    tensorFlowService: tensorFlowService,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.tensorFlowService});

  final TensorFlowService tensorFlowService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        tensorFlowService: tensorFlowService,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.tensorFlowService,
  });

  final String title;
  final TensorFlowService tensorFlowService;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _modelStatus = 'Click to run model';
  File? _image;

  Future<void> _pickImage() async {
    // Implement image picking logic here
    // For example, using image_picker package
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
      var input = List.generate(
          1, //Numero de Imagines
          (i) => List.generate(
              224, // Altura de Imagen
              (j) => List.generate(
                  224, // Ancho de Imagen
                  (k) => List.generate(
                      3, // RGB
                      (l) => 0.5))));

      var result = await widget.tensorFlowService.runModel(input);
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

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
