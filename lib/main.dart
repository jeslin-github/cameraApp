import 'package:flutter/material.dart';
import 'camera_screen.dart'; // Import the CameraScreen widget

void main() {
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),  // Set CameraScreen as the home screen
    );
  }
}
