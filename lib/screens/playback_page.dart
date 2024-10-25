import 'dart:io';

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
    final filePath = (ModalRoute.of(context)!.settings.arguments
        as Map)['file_path'] as String;
    _videoPlayerController = VideoPlayerController.file(File(filePath));
    await _videoPlayerController.initialize();
    _isReady = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _isReady
        ? ScaffoldVideoPlayback(controller: _videoPlayerController)
        : Scaffold(
            appBar: AppBar(
              title: const Text('Préparation de l\'essai'),
            ),
            body: Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ));
  }
}
