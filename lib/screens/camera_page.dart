import 'package:camera/camera.dart';
import 'package:flight_time/screens/playback_page.dart';
import 'package:flight_time/texts.dart';
import 'package:flight_time/widgets/helpers.dart';
import 'package:flight_time/widgets/waiting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  static const routeName = '/camera-page';

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
      if (!mounted) return;

      Navigator.pushNamed(context, PlaybackPage.routeName,
          arguments: {'file_path': file.path});
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      await _cameraController
          .lockCaptureOrientation(DeviceOrientation.portraitUp);
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return WaitingScreen();
    } else {
      final videoSize = computeSize(context,
          videoSize: _cameraController.value.previewSize!,
          videoAspectRatio: _cameraController.value.aspectRatio);

      return Scaffold(
        appBar: AppBar(title: Text(Texts.instance.recordingVideo)),
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
