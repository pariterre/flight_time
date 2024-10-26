import 'package:flight_time/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

class AthletesNavigationPage extends StatelessWidget {
  const AthletesNavigationPage({super.key});

  static const routeName = '/athlete-navigation-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Athletes'),
      ),
      drawer: MainDrawer(),
    );
  }
}
