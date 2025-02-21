import 'dart:io';

import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/models/video_meta_data.dart';
import 'package:flight_time/screens/playback_page.dart';
import 'package:flight_time/widgets/animated_expanding_card.dart';
import 'package:flight_time/widgets/helpers.dart';
import 'package:flight_time/widgets/main_drawer.dart';
import 'package:flight_time/widgets/translatable_text.dart';
import 'package:flight_time/widgets/waiting_screen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_package;

class AthletesNavigationPage extends StatefulWidget {
  const AthletesNavigationPage({super.key});

  static const routeName = '/athlete-navigation-page';

  @override
  State<AthletesNavigationPage> createState() => _AthletesNavigationPageState();
}

class _AthletesNavigationPageState extends State<AthletesNavigationPage> {
  Athlete? _unclassified;

  @override
  void initState() {
    _checkForUnclassifiedVideos();
    super.initState();
  }

  Future<void> _checkForUnclassifiedVideos() async {
    _unclassified = await Athletes.instance.checkForUnclassifiedVideos();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<void> _confirmDelete({required VideoMetaData metaData}) async {
    final response = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText(TextManager.instance.areYouSureDelete),
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
    );
    if (response == null || !response) return;

    await Athletes.instance.removeVideo(metaData);

    await _checkForUnclassifiedVideos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final athletes = [...Athletes.instance.athletes]
      ..sort((a, b) => a.name.compareTo(b.name));

    const height = 35.0;

    return Scaffold(
        appBar: AppBar(
          title: TranslatableText(TextManager.instance.athletes,
              style: appTitleStyle),
        ),
        drawer: MainDrawer(),
        body: _unclassified == null
            ? WaitingScreen()
            : Column(
                children: [
                  if (_unclassified!.videoMetaDataPaths.isNotEmpty)
                    AnimatedExpandingCard(
                      header: ListTile(
                          title: TranslatableText(
                        TextManager.instance.unclassified,
                        style: subtitleStyle.copyWith(
                            color: Theme.of(context)
                                .elevatedButtonTheme
                                .style!
                                .foregroundColor!
                                .resolve({})),
                      )),
                      headerBackgroundColor: Theme.of(context).primaryColor,
                      child: SizedBox(
                        child: Column(
                          children: [
                            SizedBox(
                                height: height,
                                child: _VideoMetaDataListTile(
                                    isFromCorrupted: true)),
                            SizedBox(
                              height: height *
                                  _unclassified!.videoMetaDataPaths.length
                                      .toDouble(),
                              child: ListView.builder(
                                itemCount:
                                    _unclassified!.videoMetaDataPaths.length,
                                itemBuilder: (context, index) {
                                  final videoPath =
                                      _unclassified!.videoMetaDataPaths[index];
                                  final metaData =
                                      VideoMetaData.fromCorruptedVideo(
                                    athlete: _unclassified!,
                                    trialName: path_package
                                        .basenameWithoutExtension(videoPath),
                                    baseFolder: File(videoPath).parent,
                                  );
                                  return SizedBox(
                                    height: height,
                                    child: _VideoMetaDataListTile(
                                      metaData: metaData,
                                      onDeleted: () =>
                                          _confirmDelete(metaData: metaData),
                                      onTap: () async {
                                        await Navigator.pushNamed(
                                            context, PlaybackPage.routeName,
                                            arguments: {'meta_data': metaData});
                                        await _checkForUnclassifiedVideos();
                                        setState(() {});
                                      },
                                      isFromCorrupted: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: athletes.length,
                      itemBuilder: (context, index) {
                        final athlete = athletes[index];

                        return Column(
                          children: [
                            AnimatedExpandingCard(
                              header: ListTile(
                                  title: Text(
                                athlete.name,
                                style: subtitleStyle.copyWith(
                                    color: Theme.of(context)
                                        .elevatedButtonTheme
                                        .style!
                                        .foregroundColor!
                                        .resolve({})),
                              )),
                              headerBackgroundColor: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .backgroundColor!
                                  .resolve({}),
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    SizedBox(
                                        height: height,
                                        child: _VideoMetaDataListTile()),
                                    SizedBox(
                                      height: height *
                                          athlete.videoMetaDataPaths.length
                                              .toDouble(),
                                      child: ListView.builder(
                                        itemCount:
                                            athlete.videoMetaDataPaths.length,
                                        itemBuilder: (context, index) {
                                          final metaData = VideoMetaData
                                              .fromMetaDataFile(athlete
                                                  .videoMetaDataPaths[index]);
                                          return SizedBox(
                                            height: height,
                                            child: _VideoMetaDataListTile(
                                              metaData: metaData,
                                              onDeleted: () => _confirmDelete(
                                                  metaData: metaData),
                                              onTap: () async {
                                                await Navigator.pushNamed(
                                                    context,
                                                    PlaybackPage.routeName,
                                                    arguments: {
                                                      'meta_data': metaData
                                                    });
                                                setState(() {});
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ));
  }
}

class _VideoMetaDataListTile extends StatelessWidget {
  const _VideoMetaDataListTile(
      {this.metaData,
      this.onDeleted,
      this.onTap,
      this.isFromCorrupted = false});

  final VideoMetaData? metaData;
  final Function()? onTap;
  final Function()? onDeleted;
  final bool isFromCorrupted;

  @override
  Widget build(BuildContext context) {
    final isHeader = metaData == null;

    final fligthTimeDuration = metaData == null || isFromCorrupted
        ? null
        : fligthTime(
            timeJumpStarts: metaData!.timeJumpStarts,
            timeJumpEnds: metaData!.timeJumpEnds);
    final fligthTimeText = metaData == null || isFromCorrupted
        ? null
        : '${(fligthTimeDuration!.inMilliseconds / 1000).toStringAsFixed(3)} s';
    final fligthHeightText = metaData == null || isFromCorrupted
        ? null
        : '${(flightHeight(fligthTime: fligthTimeDuration!) * 100).toStringAsFixed(1)} cm';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TranslatableText(
                isHeader
                    ? TextManager.instance.trialName
                    : TranslatableString(
                        en: metaData!.trialName, fr: metaData!.trialName),
                textAlign: TextAlign.left,
                style: mainTextStyle.copyWith(
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            if (!isFromCorrupted)
              Align(
                alignment: Alignment(0.3, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TranslatableText(
                      isHeader
                          ? TextManager.instance.flightTime
                          : TranslatableString(
                              en: fligthTimeText!, fr: fligthTimeText),
                      style: mainTextStyle.copyWith(
                          fontWeight:
                              isHeader ? FontWeight.bold : FontWeight.normal),
                    ),
                    Text(
                      ' / ',
                      style: mainTextStyle.copyWith(
                          fontWeight:
                              isHeader ? FontWeight.bold : FontWeight.normal),
                    ),
                    TranslatableText(
                      isHeader
                          ? TextManager.instance.flightHeight
                          : TranslatableString(
                              en: fligthHeightText!, fr: fligthHeightText),
                      style: mainTextStyle.copyWith(
                          fontWeight:
                              isHeader ? FontWeight.bold : FontWeight.normal),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Visibility(
                visible: !isHeader,
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
                child: IconButton(
                    onPressed: onDeleted,
                    icon: Icon(Icons.delete, color: Colors.red)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
