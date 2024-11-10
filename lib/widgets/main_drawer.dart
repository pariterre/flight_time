import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/screens/athletes_navigation_page.dart';
import 'package:flight_time/screens/camera_page.dart';
import 'package:flight_time/widgets/helpers.dart';
import 'package:flight_time/widgets/switch_language.dart';
import 'package:flight_time/widgets/translatable_text.dart';
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
              decoration: BoxDecoration(
                  color: darkBlue,
                  image: const DecorationImage(
                      image: AssetImage('assets/icons/app_icon_ios.png'),
                      opacity: 0.3)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatableText(
                    TextManager.instance.title,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SwitchLanguage(),
                ],
              )),
          ListTile(
            title: TranslatableText(TextManager.instance.camera),
            onTap: () {
              if (ModalRoute.of(context)!.settings.name ==
                  CameraPage.routeName) {
                Navigator.pop(context);
                return;
              }
              Navigator.pushReplacementNamed(context, CameraPage.routeName);
            },
          ),
          Divider(),
          ListTile(
            title: TranslatableText(TextManager.instance.playback),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, AthletesNavigationPage.routeName);
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
