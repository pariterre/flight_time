import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/screens/athletes_navigation_page.dart';
import 'package:flight_time/screens/camera_page.dart';
import 'package:flight_time/screens/playback_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Athletes.initialize();

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
