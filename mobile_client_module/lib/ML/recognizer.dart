// ignore_for_file: override_on_non_overriding_member, depend_on_referenced_packages, prefer_typing_uninitialized_variables, avoid_print

// provides a face recognition functionality using the FaceNet model.
// It loads the model, processes input images, performs inference, and
// finds the nearest match in a registered dataset.
import 'dart:math';
import 'dart:ui';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'recognition.dart';

// The Recognizer class is responsible for face recognition using a TensorFlow Lite model.
class Recognizer {
  // interpreter for running the model
  late Interpreter interpreter;

  late InterpreterOptions _interpreterOptions;

  static Map<String, Recognition> registered = {};

  // _inputShape and _outputShape for storing the shapes of input and output tensors.
  late List<int> _inputShape;
  late List<int> _outputShape;

  // _inputImage and _outputBuffer for storing the input and output data.
  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  // _inputType and _outputType for storing the data types of input and output tensors.
  late TfLiteType _inputType;
  late TfLiteType _outputType;

  // _probabilityProcessor for processing the output probabilities.
  late var _probabilityProcessor;

  // The Recognizer class implements the modelName, preProcessNormalizeOp, and
  // postProcessNormalizeOp getters from the super class.
  @override
  String get modelName => 'facenet.tflite';

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  // The loadModel method loads the TensorFlow Lite model from an asset and
  // initializes the necessary properties for inference.
  Future<void> loadModel() async {
    try {
      interpreter =
          await Interpreter.fromAsset(modelName, options: _interpreterOptions);
      print('Interpreter Created Successfully');
      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _inputType = interpreter.getInputTensor(0).type;
      _outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _probabilityProcessor =
          TensorProcessorBuilder().add(postProcessNormalizeOp).build();
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  // The _preProcess method performs pre-processing on the input image,
  // including resizing, cropping, and normalization.
  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
            _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  // The recognize method takes an Image object and a Rect location,
  // preprocesses the image, runs inference using the loaded model, processes
  // the output probabilities, finds the nearest embedding in the dataset using
  // the findNearest method, and returns a Recognition object containing the
  // recognized face's information.
  Recognition recognize(Image image, Rect location) {
    final pres = DateTime.now().millisecondsSinceEpoch;
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;
    print('Time to load image: $pre ms');
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms');
    //
    _probabilityProcessor.process(_outputBuffer);
    //     .getMapWithFloatValue();
    // final pred = getTopProbability(labeledProb);
    print(_outputBuffer.getDoubleList());
    Pair pair = findNearest(_outputBuffer.getDoubleList());
    return Recognition(
        pair.name, location, _outputBuffer.getDoubleList(), pair.distance);
  }

  // looks for the nearest embeeding in the dataset
  // and retrurns the pair <id, distance>
  findNearest(List<double> emb) {
    Pair pair = Pair("", -5);
    for (MapEntry<String, Recognition> item in registered.entries) {
      final String name = item.key;
      List<double> knownEmb = item.value.embeddings;
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - knownEmb[i];
        distance += diff * diff;
      }
      distance = sqrt(distance);
      if (pair.distance == -5 || distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
      }
    }
    return pair;
  }

  // The close method closes the interpreter when it's no longer needed.
  void close() {
    interpreter.close();
  }
}

// The Pair class is a simple data class that represents a pair of a name
// and a distance. It is used in the findNearest method to store the closest match found.
class Pair {
  String name;
  double distance;
  Pair(this.name, this.distance);
}
