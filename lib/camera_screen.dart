import 'dart:io'; // To handle files and directories
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart'; // For accessing directories

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture; // No need for late initialization

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      // Get list of available cameras
      final cameras = await availableCameras();
      // Initialize the controller with the first camera
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});  // Trigger a rebuild after initializing the controller
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera App')),
      body: _initializeControllerFuture == null
          ? Center(child: CircularProgressIndicator()) // Show loader if not initialized
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && _controller != null) {
                  // If the Future is complete and controller is available, display the preview.
                  return CameraPreview(_controller!);
                } else if (snapshot.hasError) {
                  // Display an error message if the camera setup fails
                  return Center(child: Text('Error initializing camera'));
                } else {
                  // Otherwise, display a loading indicator while the camera is initializing.
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: _controller == null
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: _takePicture,
                  child: Icon(Icons.camera),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryScreen()),
                    );
                  },
                  child: Icon(Icons.photo),
                ),
              ],
            ),
    );
  }

  Future<void> _takePicture() async {
    try {
      if (_controller != null && _initializeControllerFuture != null) {
        await _initializeControllerFuture;
        final image = await _controller!.takePicture();

        // Save image to specific folder
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/${DateTime.now()}.jpg';
        await image.saveTo(imagePath);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Picture saved to $imagePath')),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> files = directory.listSync();
    List<File> imageFiles = [];
    for (var file in files) {
      if (file.path.endsWith('.jpg')) {
        imageFiles.add(File(file.path));
      }
    }
    setState(() {
      _images = imageFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gallery')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Image.file(_images[index]);
        },
      ),
    );
  }
}
