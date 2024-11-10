import 'dart:io';

import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/models/file_manager.dart';
import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/models/video_meta_data.dart';
import 'package:flight_time/widgets/helpers.dart';
import 'package:flight_time/widgets/save_trial_dialog.dart';
import 'package:flight_time/widgets/translatable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:video_player/video_player.dart';

class ScaffoldVideoPlayback extends StatefulWidget {
  const ScaffoldVideoPlayback({
    super.key,
    required this.controller,
    required this.filePath,
    this.videoMetaData,
    required this.videoData,
  });

  final VideoPlayerController controller;
  final String filePath;
  final VideoMetaData? videoMetaData;
  final VideoData videoData;

  @override
  State<ScaffoldVideoPlayback> createState() => _ScaffoldVideoPlaybackState();
}

class _ScaffoldVideoPlaybackState extends State<ScaffoldVideoPlayback> {
  bool get _isVideoNew =>
      _metaData == null || (_metaData?.isFromCorrupted ?? false);
  late VideoMetaData? _metaData = widget.videoMetaData;

  bool _canPop = false;
  late bool _canSave = _isVideoNew;

  late String? _athleteName = _metaData?.athlete.name;
  late String? _trialName = _metaData?.trialName;

  late final _videoPlaybackWatcher = _VideoPlaybackWatcher(
      start: _metaData?.timeJumpStarts ?? Duration.zero,
      end: _metaData?.timeJumpEnds ?? widget.controller.value.duration);

  @override
  void initState() {
    widget.controller.seekTo(_videoPlaybackWatcher.start);
    super.initState();
  }

  Future<void> _onSaveVideo() async {
    final response = _isVideoNew
        ? await showDialog<Map<String, String>?>(
            context: context, builder: (context) => SaveTrialDialog())
        : {'athlete': _metaData!.athlete.name, 'trial': _metaData!.trialName};
    if (response == null) return;

    _athleteName = response['athlete'];
    _trialName = response['trial'];

    _manageFileSaving();

    _canSave = false;
    setState(() {});
  }

  void _onUpdateJumpTime() async {
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
    _canPop = _canSave
        ? await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: TranslatableText(TextManager.instance.areYouSureQuit),
              content: TranslatableText(
                  TextManager.instance.youWillLoseYourProgress),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: TranslatableText(TextManager.instance.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: TranslatableText(TextManager.instance.quit),
                ),
              ],
            ),
          )
        : true;

    if (_canPop) {
      Navigator.of(context).pop();
    }
  }

  void _manageFileSaving() async {
    final now = DateTime.now();

    // We have to copy because _metaData won't be null anymore
    final isVideoNew = _isVideoNew;

    _metaData = (isVideoNew
        ? VideoMetaData(
            athlete:
                await Athletes.instance.athleteFromNameOrAdd(_athleteName!),
            trialName: _trialName!,
            baseFolder:
                Directory('${await FileManager.dataFolder}/${_athleteName!}'),
            duration: widget.controller.value.duration,
            creationDate: now,
            lastModified: now,
            timeJumpStarts: _videoPlaybackWatcher.start,
            timeJumpEnds: _videoPlaybackWatcher.end)
        : _metaData!.copyWith(
            lastModified: now,
            timeJumpStarts: _videoPlaybackWatcher.start,
            timeJumpEnds: _videoPlaybackWatcher.end));

    // Add the video to the database
    await Athletes.instance.addVideo(_metaData!);

    // If the file is new, move it to the correct folder
    if (isVideoNew) {
      await File(widget.filePath).rename(_metaData!.videoPath);
    }
  }

  void _managePop() {
    if (_canSave && _isVideoNew) {
      // If the file is new and the user did not save it,
      // it means they just recorded it but do not want to keep it, then delete it
      File(widget.filePath).delete();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) => _managePop(),
      child: Scaffold(
          appBar: AppBar(
            title: TranslatableText(TextManager.instance.visualizingVideo),
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
            child: _VideoPlaybackSlider(_videoPlaybackWatcher,
                videoController: widget.controller,
                onUpdateRanges: _onUpdateJumpTime,
                onPlay: _onPlay,
                onPause: _onPause),
          ),
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: darkBlue,
              ),
              Center(
                child: AspectRatio(
                  aspectRatio:
                      widget.videoData.width! / widget.videoData.height!,
                  child: VideoPlayer(widget.controller),
                ),
              ),
              Positioned(
                left: 24,
                top: 24,
                child: _FightTime(videoPlaybackWatcher: _videoPlaybackWatcher),
              ),
            ],
          )),
    );
  }
}

class _FightTime extends StatelessWidget {
  const _FightTime({required _VideoPlaybackWatcher videoPlaybackWatcher})
      : _videoPlaybackWatcher = videoPlaybackWatcher;

  final _VideoPlaybackWatcher _videoPlaybackWatcher;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        color: Theme.of(context)
            .elevatedButtonTheme
            .style!
            .foregroundColor!
            .resolve({}));

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .elevatedButtonTheme
            .style!
            .backgroundColor!
            .resolve({})!.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  TranslatableText(TextManager.instance.flightTime,
                      style: textStyle),
                  Text(': ', style: textStyle),
                ],
              ),
              Row(
                children: [
                  TranslatableText(TextManager.instance.flightHeight,
                      style: textStyle),
                  Text(': ', style: textStyle),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(fligthTime(timeJumpStarts: _videoPlaybackWatcher.start, timeJumpEnds: _videoPlaybackWatcher.end).inMilliseconds / 1000).toStringAsFixed(3)} s',
                style: textStyle,
              ),
              Text(
                '${(flightHeight(fligthTime: fligthTime(timeJumpStarts: _videoPlaybackWatcher.start, timeJumpEnds: _videoPlaybackWatcher.end)) * 100).toStringAsFixed(1)} cm',
                style: textStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoPlaybackWatcher {
  Duration start;
  Duration end;

  _VideoPlaybackWatcher({required this.start, required this.end});
}

class _VideoPlaybackSlider extends StatefulWidget {
  const _VideoPlaybackSlider(
    this.watcher, {
    required this.videoController,
    required this.onUpdateRanges,
    required this.onPlay,
    required this.onPause,
  });

  final _VideoPlaybackWatcher watcher;
  final VideoPlayerController videoController;
  final Function() onUpdateRanges;
  final Function() onPlay;
  final Function() onPause;

  @override
  State<_VideoPlaybackSlider> createState() => _VideoPlaybackSliderState();
}

class _VideoPlaybackSliderState extends State<_VideoPlaybackSlider> {
  late var _ranges = RangeValues(
      widget.watcher.start.inMilliseconds /
          widget.videoController.value.duration.inMilliseconds,
      widget.watcher.end.inMilliseconds /
          widget.videoController.value.duration.inMilliseconds);
  bool _focusOnFirst = true;
  late var _playbackMarker = _ranges.start;

  @override
  void initState() {
    widget.videoController.addListener(_updatePlaybackMarkerFromPlaying);
    super.initState();
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_updatePlaybackMarkerFromPlaying);
    super.dispose();
  }

  double _getCurrentPlayingValue() {
    final duration = widget.videoController.value.duration;
    final position = widget.videoController.value.position;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  bool _isChanging = false;
  Future<void> _setPlayingValue(double value) async {
    if (_isChanging) return;
    _isChanging = true;

    await _updateVideoFrame(value);

    _playbackMarker = value;
    _isChanging = false;
    setState(() {});
  }

  void _updatePlaybackMarkerFromPlaying() {
    if (widget.videoController.value.isPlaying) {
      _playbackMarker = _getCurrentPlayingValue();
      setState(() {});
    }
  }

  Future<void> _onUpdateRanges(RangeValues values) async {
    _focusOnFirst = _ranges.start != values.start;
    await _updateVideoFrame(_focusOnFirst ? values.start : values.end);
    widget.onUpdateRanges();
    _ranges = values;

    widget.watcher.start = Duration(
        milliseconds: (values.start *
                widget.videoController.value.duration.inMilliseconds)
            .toInt());
    widget.watcher.end = Duration(
        milliseconds:
            (values.end * widget.videoController.value.duration.inMilliseconds)
                .toInt());
    setState(() {});
  }

  Future<void> _updateVideoFrame(double value) async {
    final duration = widget.videoController.value.duration;
    final position =
        Duration(milliseconds: (value * duration.inMilliseconds).toInt());
    await widget.videoController.seekTo(position);
    await Future.delayed(Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    const padding = 10.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              RangeSlider(
                values: _ranges,
                onChanged: _onUpdateRanges,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3 * padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _MarkerButton(
                          symbol: '|',
                          onTap: _playbackMarker < _ranges.end
                              ? () => _onUpdateRanges(
                                  RangeValues(_playbackMarker, _ranges.end))
                              : null,
                        ),
                        SizedBox(width: padding),
                        _MarkerButton(
                          symbol: '<<',
                          onTap: () => _setPlayingValue(_ranges.start),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MarkerButton(
                          symbol: '<',
                          onTap: () =>
                              _setPlayingValue(_playbackMarker - 0.001),
                        ),
                        SizedBox(width: padding),
                        _PlayButton(
                            isPlaying: !_isChanging &&
                                widget.videoController.value.isPlaying,
                            onPause: widget.onPause,
                            onPlay: widget.onPlay),
                        SizedBox(width: padding),
                        _MarkerButton(
                          symbol: '>',
                          onTap: () =>
                              _setPlayingValue(_playbackMarker + 0.001),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _MarkerButton(
                          symbol: '>>',
                          onTap: () => _setPlayingValue(_ranges.end),
                        ),
                        SizedBox(width: padding),
                        _MarkerButton(
                          symbol: '|',
                          onTap: _playbackMarker > _ranges.start
                              ? () => _onUpdateRanges(
                                  RangeValues(_ranges.start, _playbackMarker))
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Slider(
                value: _playbackMarker,
                onChanged: (value) => _setPlayingValue(value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const playbackButtonColor = Colors.white;
const playbackDisabledButtonColor = Colors.white30;

class _PlayButton extends StatelessWidget {
  const _PlayButton(
      {required this.isPlaying, required this.onPause, required this.onPlay});

  final bool isPlaying;
  final Function() onPause;
  final Function() onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPlaying ? onPause : onPlay,
      child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: playbackButtonColor,
          ),
          child: isPlaying
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow)),
    );
  }
}

class _MarkerButton extends StatelessWidget {
  const _MarkerButton({required this.symbol, required this.onTap});

  final String symbol;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null
                ? playbackDisabledButtonColor
                : playbackButtonColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(symbol),
          )),
    );
  }
}
