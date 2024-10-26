import 'dart:io';

import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/widgets/scaffold_video_playback.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlaybackPage extends StatefulWidget {
  const PlaybackPage({super.key});

  static const routeName = '/playback-page';

  @override
  State<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  bool _isReady = false;
  late final String _filePath;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initVideoPlayer());
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _initVideoPlayer() async {
    _filePath = (ModalRoute.of(context)!.settings.arguments as Map)['file_path']
        as String;
    _videoPlayerController = VideoPlayerController.file(File(_filePath));
    await _videoPlayerController.initialize();
    _isReady = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _isReady
        ? ScaffoldVideoPlayback(
            controller: _videoPlayerController, filePath: _filePath)
        : Scaffold(
            appBar: AppBar(title: Text(TextManager.instance.preparingTrial)),
            body: Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ));
  }
}
