import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

class ScaffoldVideoPlayback extends StatelessWidget {
  const ScaffoldVideoPlayback({super.key, required this.controller});

  final VideoPlayerController controller;

  void _onUpdateTimeline(double value) {
    final duration = controller.value.duration;
    final position = duration * value;
    controller.seekTo(position);
  }

  void _onPlay() {
    controller.play();
  }

  void _onPause() {
    controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    final videoSize = _computeSize(context,
        videoSize:
            Size(controller.value.size.width, controller.value.size.height),
        videoAspectRatio: controller.value.aspectRatio);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Visonnement de l\'essai'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                debugPrint('do something with the file');
              },
            )
          ],
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          width: double.infinity,
          height: 75,
          child: _VideoPlaybackSlider(controller,
              onUpdateTimeline: _onUpdateTimeline,
              onPlay: _onPlay,
              onPause: _onPause),
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
            ),
            Center(
              child: SizedBox(
                  width: videoSize.width,
                  height: videoSize.height,
                  child: Transform.rotate(
                      angle: pi / 2, child: VideoPlayer(controller))),
            ),
          ],
        ));
  }
}

class _VideoPlaybackSlider extends StatefulWidget {
  const _VideoPlaybackSlider(
    this.controller, {
    required this.onUpdateTimeline,
    required this.onPlay,
    required this.onPause,
  });

  final VideoPlayerController controller;
  final Function(double) onUpdateTimeline;
  final Function() onPlay;
  final Function() onPause;

  @override
  State<_VideoPlaybackSlider> createState() => _VideoPlaybackSliderState();
}

class _VideoPlaybackSliderState extends State<_VideoPlaybackSlider> {
  bool _focusOnFirst = true;
  late bool _isPlaying = widget.controller.value.isPlaying;
  var _timelineValues = RangeValues(0.0, 1.0);

  void _onUpdateTimeline(RangeValues values) {
    _focusOnFirst = _timelineValues.start != values.start;
    widget.onUpdateTimeline(_focusOnFirst ? values.start : values.end);
    _timelineValues = values;
    setState(() {});
  }

  @override
  void initState() {
    widget.controller.addListener(_updateRangesFromPlaying);
    super.initState();
  }

  void _updateRangesFromPlaying() {
    _isPlaying = widget.controller.value.isPlaying;

    final duration = widget.controller.value.duration;
    final position = widget.controller.value.position;
    final newValue = position.inMilliseconds / duration.inMilliseconds;

    // Make sure the limit cases actually works (the new value is not out of bounds)
    if (newValue < _timelineValues.start) {
      _focusOnFirst = true;
    } else if (newValue > _timelineValues.end) {
      _focusOnFirst = false;
    }

    if (_focusOnFirst) {
      _timelineValues = RangeValues(newValue, _timelineValues.end);
    } else {
      _timelineValues = RangeValues(_timelineValues.start, newValue);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .appBarTheme
                    .foregroundColor!
                    .withOpacity(0.6),
              ),
              child: _isPlaying
                  ? IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: widget.onPause,
                    )
                  : IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: widget.onPlay,
                    )),
          Expanded(
            child: RangeSlider(
              values: _timelineValues,
              onChanged: _onUpdateTimeline,
            ),
          ),
        ],
      ),
    );
  }
}
