import 'dart:io';

import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/models/file_manager_helpers.dart';
import 'package:flight_time/screens/camera_page.dart';
import 'package:flight_time/screens/playback_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Athletes.initialize();

  final dbFile = File('${await FileManagerHelpers.dataFolder}/athletes.db');
  if (await dbFile.exists()) {
    await dbFile.delete();
  }

  final athletes = Athletes.instance;
  await athletes.reset();
  athletes.addAthlete('John Doe');
  athletes.addAthlete('Jane Doe');
  athletes.addAthlete('John Smith');
  athletes.addAthlete('Jane Smith');
  athletes.addAthlete('Vladimir Putin');
  athletes.addAthlete('Donald Trump');
  athletes.addAthlete('Joe Biden');
  athletes.addAthlete('Barack Obama');
  athletes.addAthlete('George Bush');

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
          appBarTheme:
              AppBarTheme(color: Colors.teal, foregroundColor: Colors.white)),
      initialRoute: CameraPage.routeName,
      routes: {
        CameraPage.routeName: (context) => const CameraPage(),
        PlaybackPage.routeName: (context) => const PlaybackPage(),
      },
    );
  }
}
