# Smart Mirror with Real-Time Face Detection and Recognition

## Introduction

In this project, we designed an intelligent mirror with real-time face detection and recognition capabilities, aiming to be used as a smart home device. The smart mirror provides a personalized user interface to every user standing in front of it. It can offer individualized functions such as personalized medication reminders for each user and other reminders for other household members. We implemented the basic module for face recognition and used it to design the mirror's operating system and the mobile application for communication with the mirror. Firebase database service was used for backend support. To accomplish this project, we utilized FaceNetMobile, TensorFlow Lite, Google ML Kit, and the Flutter Framework. The mirror's frame and body were designed with considerations for proper air circulation and cooling of internal components. Various hardware approaches were explored to enhance the functionality and performance of the smart mirror with real-time face detection and recognition capabilities.

## Features

- Real-time face detection and recognition.
- Personalized user interface for each individual in front of the mirror.
- Customized medication reminders and other reminders for different household members.
- Integration with Firebase for backend services.

<p style="text-align: center;">
  <img width="914" alt="image" src="https://github.com/ELDERGARLIC/Smart-Mirror-with-Real-Time-Face-Detectio-and-Recognition/assets/52277462/8b36e74e-c7a0-458b-8552-d9346cb7ab9e" style="display: inline-block;">
</p>

## Technology Stack

- FaceNetMobile: Used for face recognition.
- TensorFlow Lite: Utilized for running the face recognition model.
- Google ML Kit: Used for real-time face detection.
- Flutter Framework: Used to design and develop the mirror's operating system and mobile application.
- Firebase: Employed for backend services and database integration.

## Methodology

The project consists of three main components:

1. **Smart Mirror Operating System (OS)**: Developed to control the mirror's functions and user interface.
2. **Smart Mirror Mobile Application**: Designed to communicate with the mirror and provide additional functionalities.
3. **Backend Implementation**: Utilizing Firebase database for storing user data and relevant face recognition information.

The core module, implemented using FaceNet, TensorFlow Lite, Google ML Kit, and Flutter, forms the backbone of both the Smart Mirror OS and the Smart Mirror Mobile Application. The Recognition and Recognizer classes provide face recognition functionality and data representation. The Recognizer class uses the FaceNet model to perform face recognition.

## How to Use

1. The Smart Mirror OS runs on the mirror and continuously detects faces in real-time using Google ML Kit.
2. When a face is detected, the Recognizer class processes the face using the FaceNet model for recognition.
3. If the detected face matches a registered user's face, personalized information and reminders are displayed on the mirror's interface.
4. The Smart Mirror Mobile Application can be used to manage user data, medication reminders, and other settings remotely through Firebase integration.

## More

This project presents the comprehensive design and development process of an intelligent mirror with real-time face detection and recognition capabilities. The mirror provides a personalized user interface to each individual and offers functions like personalized medication reminders and various reminders for different household members. The face recognition module forms the basis of the mirror's operating system and communication with the mobile application. The integration of Firebase backend services further enhances the functionality of the smart mirror. The project utilizes various cutting-edge technologies to achieve accurate face recognition and adaptability to different users. Additionally, special efforts were made to design the mirror's frame and body for optimal air circulation and cooling of internal components. Various hardware approaches were explored to enhance the functionality and performance of the smart mirror with real-time face detection and recognition capabilities.
