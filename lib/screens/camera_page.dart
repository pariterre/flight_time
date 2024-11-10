import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/screens/playback_page.dart';
import 'package:flight_time/widgets/main_drawer.dart';
import 'package:flight_time/widgets/translatable_text.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  static const routeName = '/camera-page';

  _recordVideo(context, MediaCapture mediaRecording) async {
    final finishedRecording = !mediaRecording.isRecordingVideo;
    if (!finishedRecording) return;

    Navigator.pushNamed(context, PlaybackPage.routeName,
        arguments: {'file_path': mediaRecording.captureRequest.path});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: TranslatableText(TextManager.instance.recordingVideo)),
      drawer: MainDrawer(),
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.video(
            videoOptions: VideoOptions(
                // TODO Test if fps can be anything on iOS
                enableAudio: false,
                ios: CupertinoVideoOptions(fps: 300))),
        sensorConfig:
            SensorConfig.single(sensor: Sensor.position(SensorPosition.back)),
        onMediaCaptureEvent: (mediaRecording) =>
            _recordVideo(context, mediaRecording),
      ),
    );
  }
}
