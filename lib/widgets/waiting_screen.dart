import 'package:flight_time/widgets/helpers.dart';
import 'package:flutter/material.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkBlue,
      child: const Center(
        child: CircularProgressIndicator(color: orange),
      ),
    );
  }
}
