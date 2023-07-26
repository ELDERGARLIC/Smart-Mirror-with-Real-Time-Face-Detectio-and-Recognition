// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors_in_immutables, library_private_types_in_public_api, unused_element, use_key_in_widget_constructors, unused_import, prefer_const_constructors

// this code sets up a Flutter application that utilizes the camera to perform
// realtime face detection and recognition. Detected faces are displayed as
// rectangles, and recognized faces are labeled with their names and recognition
// distances. The code also provides functionality to register new faces
// by displaying a registration dialog. And adds a User Interface Layer for the
// Mirror on top of the Face Recognition Module.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_detection/ML/recognizer.dart';
import 'package:realtime_face_detection/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'ML/recognition.dart';

late List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AddUserPage extends StatefulWidget {
  AddUserPage({Key? key}) : super(key: key);
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  // camera Controller
  dynamic controller;
  // to track if the system is busy processing frames
  bool isBusy = false;
  // to store the size of the screen
  late Size size;

  // store the selected camera description
  late CameraDescription description = cameras[1];

  // track the camera lens direction
  CameraLensDirection camDirec = CameraLensDirection.front;

  // a list to store recognized faces
  late List<Recognition> recognitions = [];

  // declare face detector
  late FaceDetector faceDetector;

  // declare face recognizer
  late Recognizer _recognizer;

  // declare SharedPrefrences
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    // initialize face detector
    faceDetector = FaceDetector(
        options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast));

    // initialize face recognizer
    _recognizer = Recognizer();

    // initialize camera footage
    initializeCamera();

    // initialize memory
    initializeMemory();

    // initialize registry
    initializeRegistry();
  }

  // Initializing the SharedPrefrences
  initializeMemory() async {
    Recognizer.registered = await loadMapFirestore();
  }

  // Initializing the SharedPrefrences
  initializeRegistry() async {
    prefs = await SharedPreferences.getInstance();
  }

  // In the initState() method, the face detector and face recognizer are
  // initialized, and the camera feed is initialized using the initializeCamera() method.
  initializeCamera() async {
    controller = CameraController(description, ResolutionPreset.high);
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) => {
            if (!isBusy)
              {isBusy = true, frame = image, doFaceDetectionOnFrame()}
          });
    });
  }

  // method to save the map to shared preferences
  void saveMap(Map<String, Recognition> map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = map.keys.toList();

    // Save the number of entries in the map
    await prefs.setInt('mapLength', keys.length);

    // Save each entry in the map using a unique key
    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      Recognition value = map[key]!;
      value.name = key;

      // Serialize the Recognition object to a string
      String serializedValue =
          value.toJsonString(); // Assuming Recognition has a `toJson()` method

      // Save the serialized value to shared preferences
      await prefs.setString('mapEntry_$i', serializedValue);
    }
  }

  // method to save the map to firebase cloud firestore
  void saveMapFirestore(Map<String, Recognition> map) async {
    final firestore = FirebaseFirestore.instance;
    List<String> keys = map.keys.toList();

    // Save each entry in the map using a unique key
    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      Recognition value = map[key]!;
      value.name = key;

      // Serialize the Recognition object to a string
      String serializedValue =
          value.toJsonString(); // Assuming Recognition has a `toJson()` method

      await firestore.collection('faces').add({'face': serializedValue});
    }
  }

  // method to load the map from shared preferences
  Future<Map<String, Recognition>> loadMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int mapLength = prefs.getInt('mapLength') ?? 0;
    Map<String, Recognition> map = {};

    for (int i = 0; i < mapLength; i++) {
      String key = 'mapEntry_$i';
      String? serializedValue = prefs.getString(key);
      if (serializedValue != null) {
        // Deserialize the string to a Recognition object
        Recognition value = Recognition.fromJson(
          jsonDecode(serializedValue),
        ); // Assuming Recognition has a `fromJson()` method

        // Add the entry to the map
        map[value.name] = value;
      }
    }

    return map;
  }

  // method to load the map from firebase cloud firestore
  Future<Map<String, Recognition>> loadMapFirestore() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('faces').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;
    Map<String, Recognition> map = {};

    for (int i = 0; i < documents.length; i++) {
      QueryDocumentSnapshot<Map<String, dynamic>> document = documents[i];
      Map<String, dynamic>? data = document.data();

      Recognition value = Recognition.fromJson(jsonDecode(data['face']));

      // Add the entry to the map
      map[value.name] = value;
    }

    return map;
  }

  // close all resources
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // The doFaceDetectionOnFrame() method converts the camera frame to
  // the appropriate format for face detection, passes it to the face detector,
  // and then performs face recognition on the detected faces using the
  // performFaceRecognition() method.
  dynamic _scanResults;
  CameraImage? frame;
  doFaceDetectionOnFrame() async {
    // convert frame into InputImage format
    InputImage inputImage = getInputImage();
    // pass InputImage to face detection model and detect faces
    List<Face> faces = await faceDetector.processImage(inputImage);
    // print("count=${faces.length}");
    // perform face recognition on detected faces
    performFaceRecognition(faces);
  }

  img.Image? image;
  bool register = false;

  // The performFaceRecognition() method clears the existing recognitions,
  // converts the camera frame to an image format, and then processes each
  // detected face by cropping the face region, passing it to the face recognizer,
  // and adding the recognition result to the recognitions list. If the recognition
  // distance is above a certain threshold, the face is labeled as "Unknown".
  // If the register flag is set, the method triggers the showFaceRegistrationDialogue()
  // method to allow the user to register a new face.
  performFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    // convert CameraImage to Image and rotate it so that our frame will be in a portrait
    image = convertYUV420ToImage(frame!);
    image = img.copyRotate(
      image!,
      camDirec == CameraLensDirection.front ? 270 : 90,
    );

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      // crop face
      img.Image croppedFace = img.copyCrop(
        image!,
        faceRect.left.toInt(),
        faceRect.top.toInt(),
        faceRect.width.toInt(),
        faceRect.height.toInt(),
      );

      // pass cropped face to face recognition model
      Recognition recognition = _recognizer.recognize(croppedFace, faceRect);
      if (recognition.distance > 1) {
        recognition.name = "Unknown";
      }
      recognitions.add(recognition);

      // show face registration dialogue
      if (register) {
        showFaceRegistrationDialogue(croppedFace, recognition);
        register = false;
      }
    }

    setState(() {
      isBusy = false;
      _scanResults = recognitions;
    });
  }

  // The showFaceRegistrationDialogue() method displays an alert dialog that
  // contains the cropped face image and a text field for entering the name of the person.
  // When the user clicks the "Register" button, the registration data
  // is stored in the Recognizer.registered map, and a message is displayed using a SnackBar.
  TextEditingController textEditingController = TextEditingController();
  showFaceRegistrationDialogue(img.Image croppedFace, Recognition recognition) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("User Registration", textAlign: TextAlign.center),
        alignment: Alignment.center,
        content: SizedBox(
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.memory(
                Uint8List.fromList(
                  img.encodeBmp(croppedFace),
                ),
                width: 200,
                height: 200,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Enter Username",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  Recognizer.registered.putIfAbsent(
                    textEditingController.text,
                    () => recognition,
                  );
                  textEditingController.text = "";
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("User Registered"),
                    ),
                  );
                  saveMapFirestore(Recognizer.registered);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(200, 40),
                ),
                child: const Text("Register"),
              )
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // method to convert CameraImage to Image
  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width, height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data[index] = yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  img.Image _convertYUV420(CameraImage image) {
    var imag = img.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
          planeOffset < image.height * image.width;
          planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        imag.data[planeOffset + x] = newVal;
      }
    }

    return imag;
  }

  // to convert YUV color to RGB color
  int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

  // convert CameraImage to InputImage
  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(frame!.width.toDouble(), frame!.height.toDouble());
    final camera = description;
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(frame!.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = frame!.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation!,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }

  // The buildResult() method returns a widget that displays rectangles around
  // the detected faces using a CustomPainter called FaceDetectorPainter.
  Widget buildResult() {
    if (_scanResults == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: Text('Camera is not initialized'),
      );
    }
    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter =
        FaceDetectorPainter(imageSize, _scanResults, camDirec);
    return CustomPaint(
      painter: painter,
    );
  }

  // The _toggleCameraDirection() method is responsible for switching the camera
  // direction when the camera lens direction button is pressed.
  void _toggleCameraDirection() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = cameras[1];
    } else {
      camDirec = CameraLensDirection.back;
      description = cameras[0];
    }
    await controller.stopImageStream();
    setState(() {
      controller;
    });

    initializeCamera();
  }

  // The build() method, the camera feed, face detection rectangles,
  // and camera direction buttons are displayed using a Stack widget.
  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if (controller != null) {
      // View for displaying the live camera footage
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  )
                : Container(),
          ),
        ),
      );

      // View for displaying rectangles around detected aces
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: buildResult(),
        ),
      );
    }

    // View for displaying the bar to switch camera direction or for registering faces
    stackChildren.add(
      Positioned(
        top: size.height - 190,
        left: 0,
        width: size.width,
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.cached,
                      color: Colors.white,
                    ),
                    iconSize: 40,
                    color: Colors.black,
                    onPressed: () {
                      _toggleCameraDirection();
                    },
                  ),
                  Container(
                    width: 30,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.face_unlock_rounded,
                      color: Colors.white,
                    ),
                    iconSize: 40,
                    color: Colors.black,
                    onPressed: () {
                      register = true;
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          backgroundColor: Colors.redAccent,
          child: Icon(
            Icons.close,
          ),
        ),
        backgroundColor: Colors.black,
        body: Container(
          margin: const EdgeInsets.only(top: 0),
          color: Colors.black,
          child: Stack(
            children: stackChildren,
          ),
        ),
      ),
    );
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces, this.camDire2);

  final Size absoluteImageSize;
  final List<Recognition> faces;
  CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.indigoAccent;

    for (Recognition face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          camDire2 == CameraLensDirection.front
              ? (absoluteImageSize.width - face.location.right) * scaleX
              : face.location.left * scaleX,
          face.location.top * scaleY,
          camDire2 == CameraLensDirection.front
              ? (absoluteImageSize.width - face.location.left) * scaleX
              : face.location.right * scaleX,
          face.location.bottom * scaleY,
        ),
        paint,
      );

      TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 20),
          text: "${face.name}  ${face.distance.toStringAsFixed(2)}");
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(
        canvas,
        Offset(face.location.left * scaleX, face.location.top * scaleY),
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
