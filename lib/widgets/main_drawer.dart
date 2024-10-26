import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/screens/athletes_navigation_page.dart';
import 'package:flight_time/screens/camera_page.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text(
                TextManager.instance.title,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
            title: Text(TextManager.instance.camera),
            onTap: () {
              if (ModalRoute.of(context)!.settings.name ==
                  CameraPage.routeName) {
                Navigator.pop(context);
                return;
              }
              Navigator.pushReplacementNamed(context, CameraPage.routeName);
            },
          ),
          ListTile(
            title: Text(TextManager.instance.playback),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, AthletesNavigationPage.routeName);
            },
          ),
        ],
      ),
    );
  }
}