import 'package:flight_time/models/text_manager.dart';
import 'package:flutter/material.dart';

class SwitchLanguage extends StatelessWidget {
  const SwitchLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GestureDetector(
          onTap: () => TextManager.instance.language = Language.fr,
          child: Text('Fr',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const SizedBox(width: 10),
      Text('/', style: TextStyle(color: Colors.white)),
      const SizedBox(width: 10),
      GestureDetector(
          onTap: () => TextManager.instance.language = Language.en,
          child: Text('En',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    ]);
  }
}
