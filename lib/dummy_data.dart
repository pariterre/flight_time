import 'dart:io';

import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/models/file_manager.dart';
import 'package:flight_time/models/video_meta_data.dart';

Future<VideoMetaData> _dummyVideoMetaData(String athleteName,
    {required String trialName, required Duration jumpTime}) async {
  return VideoMetaData(
    athlete: await Athletes.instance.athleteFromNameOrAdd(athleteName),
    trialName: trialName,
    baseFolder: Directory('${await FileManager.dataFolder}/$athleteName'),
    duration: Duration.zero,
    creationDate: DateTime(0),
    lastModified: DateTime(0),
    timeJumpStarts: Duration.zero,
    timeJumpEnds: jumpTime,
  );
}

Future<void> generateDummyData() async {
  final athletes = Athletes.instance;
  await athletes.reset();

  // Add an athlete to the database
  await athletes.addAthlete('John Doe');

  // Add videos to the athlete
  await athletes.addVideo(await _dummyVideoMetaData('John Doe',
      trialName: 'my_first_video', jumpTime: Duration(milliseconds: 430)));
  await athletes.addVideo(await _dummyVideoMetaData('John Doe',
      trialName: 'my_second_video', jumpTime: Duration(milliseconds: 312)));

  // Add an athlete to the database
  await athletes.addAthlete('Jane Doe');

  // Add videos to the athlete
  await athletes.addVideo(await _dummyVideoMetaData('Jane Doe',
      trialName: 'my_first_video', jumpTime: Duration(milliseconds: 250)));
  await athletes.addVideo(await _dummyVideoMetaData('Jane Doe',
      trialName: 'my_second_video', jumpTime: Duration(milliseconds: 321)));
  await athletes.addVideo(await _dummyVideoMetaData('Jane Doe',
      trialName: 'my_third_video', jumpTime: Duration(milliseconds: 423)));

  // Add an athlete to the database
  await athletes.addAthlete('Charlie');
}
