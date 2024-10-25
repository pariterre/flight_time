import 'package:flight_time/texts.dart';
import 'package:flutter/material.dart';

class SaveTrialDialog extends StatelessWidget {
  const SaveTrialDialog({super.key});

  // The save trial dialog is in two parts. The first part is the name of the athlete that can be
  // typed in and is automatically filed if the athlete exists in the database.
  // The second part is the name of the trial which is automatically set to
  // DATE_HOUR_MINUTE and can be augmented with "_NOTE"
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Texts.instance.saveTrial),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(Texts.instance.doYouWantToSaveThisTrial),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: Texts.instance.athleteName,
              hintText: Texts.instance.athleteName,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: Texts.instance.trialName,
              hintText: Texts.instance.trialName,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(Texts.instance.cancel),
        ),
      ],
    );
  }
}
