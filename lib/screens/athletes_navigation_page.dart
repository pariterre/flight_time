import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/widgets/animated_expanding_card.dart';
import 'package:flight_time/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

class AthletesNavigationPage extends StatelessWidget {
  const AthletesNavigationPage({super.key});

  static const routeName = '/athlete-navigation-page';

  @override
  Widget build(BuildContext context) {
    final names = Athletes.instance.athleteNames;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Athletes'),
        ),
        drawer: MainDrawer(),
        body: SizedBox(
          child: ListView.builder(
            itemCount: names.length,
            itemBuilder: (context, index) {
              return AnimatedExpandingCard(
                header: ListTile(title: Text(names[index])),
                child: SizedBox(
                  height: 60 * 3,
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(title: Text('Coucou$index'));
                    },
                  ),
                ),
              );
            },
          ),
        ));
  }
}
