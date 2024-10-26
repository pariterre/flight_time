import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/models/video_meta_data.dart';
import 'package:flight_time/texts.dart';
import 'package:flight_time/widgets/helpers.dart';
import 'package:flight_time/widgets/save_trial_dialog.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ScaffoldVideoPlayback extends StatefulWidget {
  const ScaffoldVideoPlayback(
      {super.key,
      required this.controller,
      required this.filePath,
      this.videoMetaData});

  final VideoPlayerController controller;
  final String filePath;
  final VideoMetaData? videoMetaData;

  @override
  State<ScaffoldVideoPlayback> createState() => _ScaffoldVideoPlaybackState();
}

class _ScaffoldVideoPlaybackState extends State<ScaffoldVideoPlayback> {
  bool get _isFileNew => _metaData == null;
  late VideoMetaData? _metaData = widget.videoMetaData;

  bool _canPop = false;
  late bool _canSave = _isFileNew;

  late String? _athleteName = _metaData?.athleteName;
  late String? _trialName = _metaData?.trialName;
  bool get _hasSaved => _athleteName != null && _trialName != null;

  final _videoPlaybackWatcher = _VideoPlaybackWatcher();

  Future<void> _onSaveVideo() async {
    final response = _isFileNew
        ? await showDialog<Map<String, String>?>(
            context: context, builder: (context) => SaveTrialDialog())
        : {'athlete': _metaData!.athleteName, 'trial': _metaData!.trialName};
    if (response == null) return;

    _athleteName = response['athlete'];
    _trialName = response['trial'];

    _manageFileSaving();

    _canSave = false;
    setState(() {});
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
    _canPop = _hasSaved
        ? true
        : await showDialog(
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

  void _manageFileSaving() async {
    final now = DateTime.now();
    final appFolder = (await getApplicationDocumentsDirectory()).path;
    _metaData = (_isFileNew
            ? VideoMetaData(
                athleteName: _athleteName!,
                trialName: _trialName!,
                baseFolder: Directory('$appFolder/${_athleteName!}'),
                duration: widget.controller.value.duration,
                creationDate: now,
                lastModified: now,
                frameJumpStarts: -1,
                frameJumpEnds: -1)
            : _metaData!)
        .copyWith(
            lastModified: DateTime.now(),
            frameJumpStarts: _videoPlaybackWatcher.frameJumpStarts,
            frameJumpEnds: _videoPlaybackWatcher.frameJumpEnds);

    // Create the target structure
    if (!(await _metaData!.baseFolder.exists())) {
      await _metaData!.baseFolder.create(recursive: true);
    }

    // Save the metadata and the video
    await File(_metaData!.path).writeAsString(
        JsonEncoder.withIndent('  ').convert(_metaData!.toJson()),
        flush: true);
    if (_isFileNew) {
      // If the file is new, move it to the correct folder and add it to the database
      await File(widget.filePath).rename(_metaData!.videoPath);
      Athletes.instance.addVideo(_metaData!);
    }
  }

  void _managePop() {
    if (!_hasSaved && _isFileNew) {
      // If the file is new and the user did not save it,
      // it means they just recorded it but do not want to keep it, then delete it
      File(widget.filePath).delete();
      return;
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
      onPopInvokedWithResult: (didPop, result) => _managePop(),
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
            child: _VideoPlaybackSlider(_videoPlaybackWatcher,
                videoController: widget.controller,
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

class _VideoPlaybackWatcher {
  int frameJumpStarts = -1;
  int frameJumpEnds = -1;
}

class _VideoPlaybackSlider extends StatefulWidget {
  const _VideoPlaybackSlider(
    this.watcher, {
    required this.videoController,
    required this.onUpdateTimeline,
    required this.onPlay,
    required this.onPause,
  });

  final _VideoPlaybackWatcher watcher;
  final VideoPlayerController videoController;
  final Function(double) onUpdateTimeline;
  final Function() onPlay;
  final Function() onPause;

  @override
  State<_VideoPlaybackSlider> createState() => _VideoPlaybackSliderState();
}

class _VideoPlaybackSliderState extends State<_VideoPlaybackSlider> {
  var _ranges = const RangeValues(0, 1);
  bool _focusOnFirst = true;
  var _playbackMarker = 0.0;

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

  void _setPlayingValue(double value) {
    final duration = widget.videoController.value.duration;
    final position =
        Duration(milliseconds: (value * duration.inMilliseconds).toInt());
    widget.videoController.seekTo(position);
    _playbackMarker = value;
    setState(() {});
  }

  void _updatePlaybackMarkerFromPlaying() {
    if (widget.videoController.value.isPlaying) {
      _playbackMarker = _getCurrentPlayingValue();
      setState(() {});
    }
  }

  void _onUpdateRanges(RangeValues values) {
    _focusOnFirst = _ranges.start != values.start;
    widget.onUpdateTimeline(_focusOnFirst ? values.start : values.end);
    _ranges = values;

    widget.watcher.frameJumpStarts =
        (values.start * widget.videoController.value.duration.inMilliseconds)
            .toInt();
    widget.watcher.frameJumpEnds =
        (values.end * widget.videoController.value.duration.inMilliseconds)
            .toInt();
    setState(() {});
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MarkerButton(
                    onTap: _playbackMarker < _ranges.end
                        ? () => _onUpdateRanges(
                            RangeValues(_playbackMarker, _ranges.end))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  _PlayButton(
                      isPlaying: widget.videoController.value.isPlaying,
                      onPause: widget.onPause,
                      onPlay: widget.onPlay),
                  const SizedBox(width: 12),
                  _MarkerButton(
                    onTap: _playbackMarker > _ranges.start
                        ? () => _onUpdateRanges(
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
