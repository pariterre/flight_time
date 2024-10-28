import 'dart:io';

import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/models/file_manager.dart';
import 'package:flight_time/models/video_meta_data.dart';
import 'package:flight_time/screens/athletes_navigation_page.dart';
import 'package:flight_time/screens/camera_page.dart';
import 'package:flight_time/screens/playback_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Athletes.initialize();

  final dbFile = File('${await FileManager.dataFolder}/athletes.db');
  if (await dbFile.exists()) {
    await dbFile.delete();
  }

  final athletes = Athletes.instance;
  await athletes.reset();
  await athletes.addAthlete('John Doe');
  await athletes.addAthlete('Jane Doe');
  await athletes.addAthlete('John Smith');
  await athletes.addAthlete('Jane Smith');
  await athletes.addAthlete('Vladimir Putin');
  await athletes.addAthlete('Donald Trump');
  await athletes.addAthlete('Joe Biden');
  await athletes.addAthlete('Barack Obama');
  await athletes.addAthlete('George Bush');

  athletes.addVideo(VideoMetaData(
      athlete: Athletes.instance.athletes[0],
      trialName: 'trialName',
      baseFolder: Directory('${await FileManager.baseFolder}/mockFolder'),
      duration: Duration(seconds: 5),
      creationDate: DateTime.now(),
      lastModified: DateTime.now(),
      timeJumpStarts: Duration(milliseconds: 100),
      timeJumpEnds: Duration(milliseconds: 500))
    ..writeToDisk());
  athletes.addVideo(VideoMetaData(
      athlete: Athletes.instance.athletes[0],
      trialName: 'trialName1',
      baseFolder: Directory('${await FileManager.baseFolder}/mockFolder'),
      duration: Duration(seconds: 5),
      creationDate: DateTime.now(),
      lastModified: DateTime.now(),
      timeJumpStarts: Duration(milliseconds: 200),
      timeJumpEnds: Duration(milliseconds: 500))
    ..writeToDisk());
  athletes.addVideo(VideoMetaData(
      athlete: Athletes.instance.athletes[0],
      trialName: 'trialName2',
      baseFolder: Directory('${await FileManager.baseFolder}/mockFolder'),
      duration: Duration(seconds: 5),
      creationDate: DateTime.now(),
      lastModified: DateTime.now(),
      timeJumpStarts: Duration(milliseconds: 100),
      timeJumpEnds: Duration(milliseconds: 400))
    ..writeToDisk());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal[100],
          appBarTheme:
              AppBarTheme(color: Colors.teal, foregroundColor: Colors.white)),
      initialRoute: CameraPage.routeName,
      routes: {
        CameraPage.routeName: (context) => const CameraPage(),
        PlaybackPage.routeName: (context) => const PlaybackPage(),
        AthletesNavigationPage.routeName: (context) =>
            const AthletesNavigationPage(),
      },
    );
  }
}
