import 'dart:async';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

enum FpsOptions {
  fps30,
  fps60,
  fps120,
  fps240,
  ;

  double get value {
    switch (this) {
      case FpsOptions.fps30:
        return 30.0;
      case FpsOptions.fps60:
        return 60.0;
      case FpsOptions.fps120:
        return 120.0;
      case FpsOptions.fps240:
        return 240.0;
    }
  }

  @override
  String toString() {
    switch (this) {
      case FpsOptions.fps30:
        return '30';
      case FpsOptions.fps60:
        return '60';
      case FpsOptions.fps120:
        return '120';
      case FpsOptions.fps240:
        return '240';
    }
  }
}

class _VideoPlaybackWatcher {
  Duration start;
  Duration end;

  FpsOptions fps;

  _VideoPlaybackWatcher(
      {required this.start, required this.end, required this.fps});
}

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
      end: _metaData?.timeJumpEnds ?? widget.controller.value.duration,
      fps: FpsOptions.fps30);

  final _videoPlaybackWatcherCompleter = Completer<void>();

  @override
  void initState() {
    widget.controller.seekTo(_videoPlaybackWatcher.start);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final preferences = await SharedPreferences.getInstance();
      final fps = preferences.getDouble('fps') ?? FpsOptions.fps30.value;
      _videoPlaybackWatcher.fps = FpsOptions.values.firstWhere(
          (element) => element.value == fps,
          orElse: () => FpsOptions.fps30);
      _videoPlaybackWatcherCompleter.complete();
      setState(() {});
    });
    _showWarningMessage();
    super.initState();
  }

  Future<void> _showWarningMessage() async {
    final preferences = await SharedPreferences.getInstance();
    final showWarning = preferences.getBool('showFpsWarning') ?? true;
    if (!showWarning) return;

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
        context: context,
        builder: (context) => PopScope(
          onPopInvokedWithResult: (didPop, result) {
            preferences.setBool('showFpsWarning', false);
          },
          child: AlertDialog(
            title: TranslatableText(TextManager.instance.fpsWarningTitle),
            content: TranslatableText(TextManager.instance.fpsWarningDetails),
            actions: [
              TextButton(
                onPressed: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: TranslatableText(TextManager.instance.confirm),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _onChangedFps(FpsOptions fps) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble('fps', fps.value);
    _videoPlaybackWatcher.fps = fps;
    setState(() {});
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
            title: TranslatableText(TextManager.instance.visualizingVideo,
                style: appTitleStyle),
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
              Positioned(
                right: 24,
                top: 24,
                child: FutureBuilder(
                    future: _videoPlaybackWatcherCompleter.future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Container();
                      }
                      return _FpsSelector(
                          initialValue: _videoPlaybackWatcher.fps,
                          onFpsChanged: _onChangedFps);
                    }),
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
    final fligthTimeDuration = fligthTime(
        timeJumpStarts: _videoPlaybackWatcher.start,
        timeJumpEnds: _videoPlaybackWatcher.end);
    final fligthTimeText =
        '${(fligthTimeDuration.inMilliseconds / 1000).toStringAsFixed(3)} s';
    final fligthHeightText =
        '${(flightHeight(fligthTime: fligthTimeDuration) * 100).toStringAsFixed(1)} cm';

    final textStyle = mainTextStyle.copyWith(
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
              Text(fligthTimeText, style: textStyle),
              Text(fligthHeightText, style: textStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _FpsSelector extends StatefulWidget {
  const _FpsSelector({required this.initialValue, required this.onFpsChanged});

  final FpsOptions initialValue;
  final Function(FpsOptions) onFpsChanged;

  @override
  State<_FpsSelector> createState() => _FpsSelectorState();
}

class _FpsSelectorState extends State<_FpsSelector> {
  bool _isExpanded = false;
  late FpsOptions _selectedFps = widget.initialValue;

  void _onFpsChanged(FpsOptions fps) {
    _selectedFps = fps;
    widget.onFpsChanged(_selectedFps);
    _isExpanded = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = mainTextStyle.copyWith(
        color: Theme.of(context)
            .elevatedButtonTheme
            .style!
            .foregroundColor!
            .resolve({}));

    final backgroundColor = Theme.of(context)
        .elevatedButtonTheme
        .style!
        .backgroundColor!
        .resolve({})!.withOpacity(0.7);

    final width = 110.0;
    final height = 45.0;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: _isExpanded
                  ? BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))
                  : BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('FPS: ${_selectedFps.toString()}', style: textStyle),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
        if (_isExpanded) Container(height: MediaQuery.of(context).size.height),
        if (_isExpanded)
          Positioned(
            left: 0,
            top: height,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
              ),
              child: Column(
                children: FpsOptions.values
                    .map((e) => GestureDetector(
                        onTap: () => _onFpsChanged(e),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('FPS: ${e.toString()}', style: textStyle),
                        )))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
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
  Future<void> _setPlayingValue(double value, {bool force = false}) async {
    if (value < 0 || value > 1) return;
    _playbackMarker = value;
    setState(() {});
    _updateVideoFrame(value, force: force);
  }

  void _updatePlaybackMarkerFromPlaying() {
    if (widget.videoController.value.isPlaying) {
      _playbackMarker = _getCurrentPlayingValue();
      setState(() {});
    }
  }

  Future<void> _onUpdateRanges(RangeValues values, {bool force = false}) async {
    if (_ranges.start == values.start && _ranges.end == values.end) return;

    _focusOnFirst = _ranges.start != values.start;
    _ranges = values;
    widget.onUpdateRanges();
    widget.watcher.start = Duration(
        milliseconds: (values.start *
                widget.videoController.value.duration.inMilliseconds)
            .toInt());
    widget.watcher.end = Duration(
        milliseconds:
            (values.end * widget.videoController.value.duration.inMilliseconds)
                .toInt());
    setState(() {});

    _setPlayingValue(_focusOnFirst ? values.start : values.end, force: force);
  }

  Future<void> _updateVideoFrame(double value, {bool force = false}) async {
    if (_isChanging) {
      if (!force) return;

      while (_isChanging) {
        await Future.delayed(Duration(milliseconds: 10));
      }
    }

    _isChanging = true;
    final duration = widget.videoController.value.duration;
    final position =
        Duration(milliseconds: (value * duration.inMilliseconds).toInt());
    await widget.videoController.seekTo(position);

    // On Android it helps to wait a bit before setting the playback state
    if (Platform.isAndroid) {
      await Future.delayed(Duration(milliseconds: 125));
    }
    _isChanging = false;
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
                onChangeEnd: (value) => _onUpdateRanges(value, force: true),
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
                          onTap: () => _setPlayingValue(
                              _playbackMarker - (1 / widget.watcher.fps.value)),
                        ),
                        SizedBox(width: padding),
                        _PlayButton(
                            isPlaying: widget.videoController.value.isPlaying,
                            onPause: () {
                              widget.onPause();
                              setState(() {});
                            },
                            onPlay: () {
                              widget.onPlay();
                              setState(() {});
                            }),
                        SizedBox(width: padding),
                        _MarkerButton(
                          symbol: '>',
                          onTap: () => _setPlayingValue(
                              _playbackMarker + (1 / widget.watcher.fps.value)),
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
                onChanged: _setPlayingValue,
                onChangeEnd: (value) => _setPlayingValue(value, force: true),
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
