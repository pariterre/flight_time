import 'package:camera/camera.dart';
import 'package:flight_time/screens/video_page.dart';
import 'package:flutter/material.dart';

Size _computeSize(context,
    {required Size videoSize, required double videoAspectRatio}) {
  final width = videoSize.width;
  final height = videoSize.height;

  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final widthSizeFactor = width / screenWidth;
  final heightSizeFactor = height / screenHeight;

  final sizeFactor =
      widthSizeFactor > heightSizeFactor ? widthSizeFactor : heightSizeFactor;

  return Size(videoSize.width / sizeFactor,
      videoSize.height * videoAspectRatio / sizeFactor);
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(back, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(filePath: file.path),
      );
      if (!mounted) return;
      // TODO Better navigation system to prevent "back" without saving
      Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    } else {
      final videoSize = _computeSize(context,
          videoSize: _cameraController.value.previewSize!,
          videoAspectRatio: _cameraController.value.aspectRatio);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Enregistrement vidéo'),
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          width: double.infinity,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording
                  ? Colors.red.withOpacity(0.5)
                  : Theme.of(context)
                      .appBarTheme
                      .foregroundColor!
                      .withOpacity(0.6),
            ),
            child: IconButton(
              color: Colors.red,
              icon: Icon(_isRecording ? Icons.stop : Icons.circle),
              onPressed: () => _recordVideo(),
            ),
          ),
        ),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
              ),
              SizedBox(
                  width: videoSize.width,
                  height: videoSize.height,
                  child: CameraPreview(_cameraController)),
            ],
          ),
        ),
      );
    }
  }
}
