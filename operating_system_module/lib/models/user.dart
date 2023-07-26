import 'package:realtime_face_detection/ML/recognition.dart';

// User Model
class User {
  Recognition face;
  Map<String, String> reminders;
  Map<String, String> medicines;

  User({required this.face, required this.reminders, required this.medicines});
}
