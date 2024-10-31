import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/models/video_meta_data.dart';
import 'package:flight_time/screens/playback_page.dart';
import 'package:flight_time/widgets/animated_expanding_card.dart';
import 'package:flight_time/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

class AthletesNavigationPage extends StatefulWidget {
  const AthletesNavigationPage({super.key});

  static const routeName = '/athlete-navigation-page';

  @override
  State<AthletesNavigationPage> createState() => _AthletesNavigationPageState();
}

class _AthletesNavigationPageState extends State<AthletesNavigationPage> {
  @override
  void initState() {
    Athletes.instance.checkForLooseVideos();
    super.initState();
  }

  Future<void> _confirmDelete({required VideoMetaData metaData}) async {
    final response = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TextManager.instance.areYouSureDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(TextManager.instance.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(TextManager.instance.quit),
          ),
        ],
      ),
    );
    if (response == null || !response) return;

    await Athletes.instance.removeVideo(metaData);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final athletes = [...Athletes.instance.athletes]
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
        appBar: AppBar(
          title: const Text('Athletes'),
        ),
        drawer: MainDrawer(),
        body: SizedBox(
          child: ListView.builder(
            itemCount: athletes.length,
            itemBuilder: (context, index) {
              const height = 35.0;
              final athlete = athletes[index];

              return AnimatedExpandingCard(
                header: ListTile(title: Text(athlete.name)),
                headerBackgroundColor: Theme.of(context).primaryColor,
                child: SizedBox(
                  child: Column(
                    children: [
                      SizedBox(height: height, child: _VideoMetaDataListTile()),
                      SizedBox(
                        height: height *
                            athlete.videoMetaDataPaths.length.toDouble(),
                        child: ListView.builder(
                          itemCount: athlete.videoMetaDataPaths.length,
                          itemBuilder: (context, index) {
                            final metaData = VideoMetaData.fromMetaDataFile(
                                athlete.videoMetaDataPaths[index]);
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
              );
            },
          ),
        ));
  }
}

class _VideoMetaDataListTile extends StatelessWidget {
  const _VideoMetaDataListTile({this.metaData, this.onDeleted, this.onTap});

  final VideoMetaData? metaData;
  final Function()? onTap;
  final Function()? onDeleted;

  @override
  Widget build(BuildContext context) {
    final isHeader = metaData == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isHeader ? TextManager.instance.trialName : metaData!.trialName,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            Align(
              alignment: Alignment(0.3, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isHeader
                        ? TextManager.instance.flightTime
                        : '${(metaData!.fligthTime.inMilliseconds / 1000).toStringAsFixed(3)} s',
                    style: TextStyle(
                        fontWeight:
                            isHeader ? FontWeight.bold : FontWeight.normal),
                  ),
                  Text(
                    ' / ',
                    style: TextStyle(
                        fontWeight:
                            isHeader ? FontWeight.bold : FontWeight.normal),
                  ),
                  Text(
                    isHeader
                        ? TextManager.instance.flightHeight
                        : '${(metaData!.flightHeight * 100).toStringAsFixed(1)} cm',
                    style: TextStyle(
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
