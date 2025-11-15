// lib/widgets/windows_camera_capture.dart
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class WindowsCameraCapture extends StatefulWidget {
  const WindowsCameraCapture({super.key});

  @override
  State<WindowsCameraCapture> createState() => _WindowsCameraCaptureState();
}

class _WindowsCameraCaptureState extends State<WindowsCameraCapture> {
  CameraController? _controller;
  Future<void>? _initFuture;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    if (!Platform.isWindows) return; // Ce widget est dédié à Windows
    _initFuture = _init();
  }

  Future<void> _init() async {
    _cameras = await availableCameras(); // Liste des webcams
    final camera = _cameras.first;       // Prends la 1re
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final file = await _controller!.takePicture(); // -> XFile

    // Option: déplacer la photo dans Documents/DStore
    final dir = await getApplicationDocumentsDirectory();
    final outPath = '${dir.path}/dstore_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await file.saveTo(outPath);

    if (!mounted) return;
    Navigator.of(context).pop(outPath); // Renvoie le chemin sélectionné
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return const Center(child: Text('Caméra desktop non disponible.'));
    }
    return FutureBuilder(
      future: _initFuture,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller == null || !_controller!.value.isInitialized) {
          return const Center(child: Text('Impossible d’initialiser la caméra.'));
        }
        return Column(
          children: [
            Expanded(child: CameraPreview(_controller!)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Prendre la photo'),
              ),
            ),
          ],
        );
      },
    );
  }
}
