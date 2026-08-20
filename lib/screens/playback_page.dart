import 'dart:io';

import 'package:flight_time/models/video_meta_data.dart';
import 'package:flight_time/widgets/scaffold_video_playback.dart';
import 'package:flight_time/widgets/waiting_screen.dart';
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
  VideoMetaData? _metaData;
  String? _filePath;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initVideoPlayer();
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initVideoPlayer() async {
    _metaData =
        (ModalRoute.of(context)!.settings.arguments as Map)['meta_data']
            as VideoMetaData?;
    _filePath = _metaData == null
        ? (ModalRoute.of(context)!.settings.arguments as Map)['file_path']
              as String?
        : _metaData!.videoPath;

    final controller = VideoPlayerController.file(File(_filePath!));
    _videoPlayerController = controller;
    await controller.initialize();
    if (!mounted) return;
    _isReady = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _isReady
        ? ScaffoldVideoPlayback(
            controller: _videoPlayerController!,
            filePath: _filePath!,
            videoMetaData: _metaData,
          )
        : WaitingScreen();
  }
}
