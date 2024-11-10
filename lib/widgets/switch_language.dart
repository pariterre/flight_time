import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/widgets/helpers.dart';
import 'package:flight_time/widgets/translatable_text.dart';
import 'package:flutter/material.dart';

class SwitchLanguage extends StatefulWidget {
  const SwitchLanguage({super.key});

  @override
  State<SwitchLanguage> createState() => _SwitchLanguageState();
}

class _SwitchLanguageState extends State<SwitchLanguage> {
  @override
  void initState() {
    super.initState();
    TextManager.instance.onLanguageChanged.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    TextManager.instance.onLanguageChanged.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tm = TextManager.instance;

    return Row(children: [
      GestureDetector(
          onTap: () => tm.language = Language.fr,
          child: TranslatableText(tm.french,
              style: subtitleStyle.copyWith(
                  color: Colors.white,
                  fontWeight: tm.language == Language.fr
                      ? FontWeight.bold
                      : FontWeight.normal))),
      const SizedBox(width: 10),
      Text('/', style: subtitleStyle.copyWith(color: Colors.white)),
      const SizedBox(width: 10),
      GestureDetector(
          onTap: () => tm.language = Language.en,
          child: TranslatableText(tm.english,
              style: subtitleStyle.copyWith(
                  color: Colors.white,
                  fontWeight: tm.language == Language.en
                      ? FontWeight.bold
                      : FontWeight.normal))),
    ]);
  }
}
