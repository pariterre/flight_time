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
  bool _canSave = false;

  Future<void> _onSaveVideo() async {
    final response = await showDialog(
        context: context, builder: (context) => SaveTrialDialog());
    if (response == null) return;

    debugPrint(
        'Saving trial with athlete: ${response['athlete']} and trial: ${response['trial']}');
  }

  void _onUpdateTimeline(double value) {
    final duration = widget.controller.value.duration;
    final position = duration * value;
    widget.controller.seekTo(position);
    _canSave = true;
    setState(() {});
  }

  void _onPlay() {
    widget.controller.play();
    setState(() {});
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
                icon: const Icon(Icons.save),
                onPressed: _canSave ? _onSaveVideo : null,
              )
            ],
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            width: double.infinity,
            height: 150,
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
  var _ranges = RangeValues(0.0, 1.0);
  var _playbackMarker = 0.0;

  void _onUpdateTimeline(RangeValues values) {
    _focusOnFirst = _ranges.start != values.start;
    widget.onUpdateTimeline(_focusOnFirst ? values.start : values.end);
    _ranges = values;
    setState(() {});
  }

  @override
  void initState() {
    widget.controller.addListener(_updatePlaybackMarkerFromPlaying);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePlaybackMarkerFromPlaying);
    super.dispose();
  }

  double _getCurrentPlayingValue() {
    final duration = widget.controller.value.duration;
    final position = widget.controller.value.position;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  void _setPlayingValue(double value) {
    final duration = widget.controller.value.duration;
    final position =
        Duration(milliseconds: (value * duration.inMilliseconds).toInt());
    widget.controller.seekTo(position);
    _playbackMarker = value;
    setState(() {});
  }

  void _updatePlaybackMarkerFromPlaying() {
    if (widget.controller.value.isPlaying) {
      _playbackMarker = _getCurrentPlayingValue();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const padding = 10.0;
    final currentPlayingValue = _getCurrentPlayingValue();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              RangeSlider(
                values: _ranges,
                onChanged: _onUpdateTimeline,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MarkerButton(
                    onTap: _playbackMarker < _ranges.end
                        ? () => _onUpdateTimeline(
                            RangeValues(_playbackMarker, _ranges.end))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  _PlayButton(
                      isPlaying: widget.controller.value.isPlaying,
                      onPause: widget.onPause,
                      onPlay: widget.onPlay),
                  const SizedBox(width: 12),
                  _MarkerButton(
                    onTap: _playbackMarker > _ranges.start
                        ? () => _onUpdateTimeline(
                            RangeValues(_ranges.start, _playbackMarker))
                        : null,
                  ),
                ],
              ),
              Slider(
                value: _playbackMarker,
                onChanged: (value) {
                  _setPlayingValue(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton(
      {required this.isPlaying, required this.onPause, required this.onPlay});

  final bool isPlaying;
  final Function() onPause;
  final Function() onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              Theme.of(context).appBarTheme.foregroundColor!.withOpacity(0.6),
        ),
        child: isPlaying
            ? IconButton(
                icon: const Icon(Icons.pause),
                onPressed: onPause,
              )
            : IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: onPlay,
              ));
  }
}

class _MarkerButton extends StatelessWidget {
  const _MarkerButton({required this.onTap});

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null
                ? Colors.black.withOpacity(0.2)
                : Theme.of(context)
                    .appBarTheme
                    .foregroundColor!
                    .withOpacity(0.6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('|'),
          )),
    );
  }
}
