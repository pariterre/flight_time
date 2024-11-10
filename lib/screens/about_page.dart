import 'package:flight_time/models/text_manager.dart';
import 'package:flight_time/widgets/helpers.dart';
import 'package:flight_time/widgets/main_drawer.dart';
import 'package:flight_time/widgets/translatable_text.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const routeName = '/about-page';

  @override
  Widget build(BuildContext context) {
    final tm = TextManager.instance;

    return Scaffold(
        appBar: AppBar(
          title: TranslatableText(TextManager.instance.about,
              style: appTitleStyle),
        ),
        drawer: MainDrawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Section(
                    title: tm.howTheAppWorks,
                    body: TranslatableText(tm.howTheAppWorksDetails)),
                const _SectionDivider(),
                _Section(
                    title: tm.videoTutorialTitle,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatableText(tm.videoTutorialDetails),
                        const SizedBox(height: 10),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Center(
                            child: TranslatableText(tm.videoTutorialLink),
                          ),
                        )
                      ],
                    )),
                const _SectionDivider(),
                _Section(
                    title: tm.acknowledgementsTitle,
                    body: TranslatableText(tm.acknowledgementsDetails)),
                const _Logos(),
                SizedBox(height: 150),
              ],
            ),
          ),
        ));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final TranslatableString title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TranslatableText(
            title,
            style: subtitleStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 12.0), child: body),
        ]);
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Logos extends StatelessWidget {
  const _Logos();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/icons/patinage_quebec_logo.png', height: 100),
            Image.asset('assets/icons/s2m_logo.png', height: 100),
          ],
        ),
      ],
    );
  }
}
