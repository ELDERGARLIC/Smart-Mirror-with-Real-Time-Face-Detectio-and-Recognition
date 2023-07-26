// ignore_for_file: file_names
import 'dart:ui';
import 'dart:convert';

// The Recognition class represents a recognized face.
class Recognition {
  // name associated with the recognized face.
  String name;

  // object that represents the bounding box location of the face in the image.
  Rect location;

  // A list of doubles that represents the facial embeddings or features extracted from the face.
  List<double> embeddings;

  // A double value that represents the distance or similarity score between the recognized face and a reference face.
  double distance;

  /// Constructs a Category.
  Recognition(this.name, this.location, this.embeddings, this.distance);

  // Convert the Recognition object to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': {
        'left': location.left,
        'top': location.top,
        'right': location.right,
        'bottom': location.bottom,
      },
      'embeddings': embeddings,
      'distance': distance,
    };
  }

  // Create a Recognition object from a JSON representation
  factory Recognition.fromJson(Map<String, dynamic> json) {
    return Recognition(
      json['name'],
      Rect.fromLTRB(
        json['location']['left'],
        json['location']['top'],
        json['location']['right'],
        json['location']['bottom'],
      ),
      List<double>.from(json['embeddings']),
      json['distance'],
    );
  }

  // Convert the Recognition object to a JSON string
  String toJsonString() {
    return json.encode(toJson());
  }

  // Create a Recognition object from a JSON string
  factory Recognition.fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return Recognition.fromJson(json);
  }
}
