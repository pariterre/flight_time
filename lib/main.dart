import 'package:flight_time/screens/playback_page.dart';
import 'package:flutter/material.dart';
import 'package:flight_time/screens/camera_page.dart';

void main() {
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
