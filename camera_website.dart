import 'dart:io'; 
import 'package:flutter/material.dart'; 
import 'package:camera/camera.dart'; 
import 'package:flutter/foundation.dart'; 
List<CameraDescription> cameras = [];

Future<void> main() async { 
WidgetsFlutterBinding.ensureInitialized(); 
cameras = await availableCameras(); 
runApp(const CameraApp()); 
} 
class CameraApp extends StatelessWidget { 
const CameraApp({super.key}); 
 
  @override 
  Widget build(BuildContext context) { 
    return const MaterialApp( 
      debugShowCheckedModeBanner: false, 
      home: CameraScreen(), 
    ); 
  } 
} 
 
class CameraScreen extends StatefulWidget { 
  const CameraScreen({super.key}); 
 
  @override 
  State<CameraScreen> createState() => _CameraScreenState(); 
} 
 
class _CameraScreenState extends State<CameraScreen> { 
 
  CameraController? controller; 
  int cameraIndex = 0; 
  XFile? capturedImage; 
 
  @override 
  void initState() { 
    super.initState(); 
    startCamera(); 
  } 
 
  Future<void> startCamera() async { 
 
    controller = CameraController( 
      cameras[cameraIndex], 
      ResolutionPreset.high, 
    ); 
 
    await controller!.initialize(); 
 
    if (mounted) { 
      setState(() {}); 
    } 
  } 
 
  Future<void> takePhoto() async { 
 
    if (controller == null || !controller!.value.isInitialized) return; 
 
    final image = await controller!.takePicture(); 
 
    setState(() { 
      capturedImage = image; 
    }); 
  } 
 
  Future<void> switchCamera() async { 
 
    cameraIndex = (cameraIndex + 1) % cameras.length; 
 
    await controller?.dispose(); 
 
    startCamera(); 
  } 
 
  Future<void> retake() async { 
 
    setState(() { 
      capturedImage = null; 
    }); 
 
    await controller?.dispose(); 
 
    startCamera(); 
  } 
 
  @override 
  void dispose() { 
    controller?.dispose(); 
    super.dispose(); 
  } 
 
  @override 
  Widget build(BuildContext context) { 
 
    if (controller == null || !controller!.value.isInitialized) { 
      return const Scaffold( 
        body: Center(child: CircularProgressIndicator()), 
      ); 
    } 
 
    return Scaffold( 
      backgroundColor: Colors.black, 
      body: Stack( 
        children: [ 
 
          /// Captured Image 
          if (capturedImage != null) 
            Positioned.fill( 
              child: kIsWeb 
                  ? Image.network( 
                      capturedImage!.path, 
                      fit: BoxFit.cover, 
                    ) 
                  : Image.file( 
                      File(capturedImage!.path), 
                      fit: BoxFit.cover, 
                    ), 
            ) 
 
          /// Camera Preview 
          else 
            Positioned.fill( 
              child: CameraPreview(controller!), 
            ), 
 
          /// Top Bar 
          Positioned( 
            top: 50, 
            left: 20, 
            right: 20, 
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [ 
 
                IconButton( 
                  onPressed: switchCamera, 
                  icon: const Icon( 
                    Icons.flip_camera_ios, 
                    color: Colors.white, 
                  ), 
                ), 
 
                const Text( 
                  "Camera App", 
                  style: TextStyle( 
                    color: Colors.white, 
                    fontSize: 18, 
                  ), 
                ), 
 
                const Icon( 
                  Icons.flash_off, 
                  color: Colors.white, 
                ) 
              ], 
            ), 
          ), 
 
          /// Bo om Bu on 
          Positioned( 
            bottom: 40, 
            left: 0, 
            right: 0, 
            child: Center( 
              child: capturedImage == null 
 
                  /// Capture Bu on 
                  ? GestureDetector( 
                      onTap: takePhoto, 
                      child: Container( 
                        width: 80, 
                        height: 80, 
                        decoration: BoxDecoration( 
                          shape: BoxShape.circle, 
                          border: Border.all( 
                            color: Colors.white, 
                            width: 5, 
                          ), 
                        ), 
                      ), 
                    ) 
 
                  /// Retake Bu on 
                  : ElevatedButton( 
                      onPressed: retake, 
                      child: const Text("Retake"), 
                    ), 
            ), 
          ), 
        ], 
      ), 
    ); 
  } 
} 
