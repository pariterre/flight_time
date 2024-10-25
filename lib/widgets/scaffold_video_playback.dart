import 'dart:math';

import 'package:flight_time/texts.dart';
import 'package:flight_time/widgets/helpers.dart';
import 'package:flight_time/widgets/save_trial_dialog.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ScaffoldVideoPlayback extends StatefulWidget {
  const ScaffoldVideoPlayback({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  State<ScaffoldVideoPlayback> createState() => _ScaffoldVideoPlaybackState();
}

class _ScaffoldVideoPlaybackState extends State<ScaffoldVideoPlayback> {
  bool _canPop = false;

  void _onSaveVideo() {
    showDialog(context: context, builder: (context) => SaveTrialDialog());
  }

  void _onUpdateTimeline(double value) {
    final duration = widget.controller.value.duration;
    final position = duration * value;
    widget.controller.seekTo(position);
  }

  void _onPlay() {
    widget.controller.play();
  }

  void _onPause() {
    widget.controller.pause();
  }

  void _areYouSureDialog(context) async {
    _canPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Texts.instance.areYouSureToQuit),
        content: Text(Texts.instance.youWillLoseYourProgress),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(Texts.instance.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(Texts.instance.quit),
          ),
        ],
      ),
    );

    if (_canPop) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoSize = computeSize(context,
        videoSize: Size(widget.controller.value.size.width,
            widget.controller.value.size.height),
        videoAspectRatio: widget.controller.value.aspectRatio);

    return PopScope(
      canPop: _canPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(Texts.instance.visualizingVideo),
            elevation: 0,
            leading: IconButton(
                onPressed: () => _areYouSureDialog(context),
                icon: Icon(Icons.arrow_back)),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _onSaveVideo,
              )
            ],
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            width: double.infinity,
            height: 75,
            child: _VideoPlaybackSlider(widget.controller,
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
                        angle: pi / 2, child: VideoPlayer(widget.controller))),
              ),
            ],
          )),
    );
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
