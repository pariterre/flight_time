import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/texts.dart';
import 'package:flutter/material.dart';

class SaveTrialDialog extends StatefulWidget {
  const SaveTrialDialog({super.key});

  @override
  State<SaveTrialDialog> createState() => _SaveTrialDialogState();
}

class _SaveTrialDialogState extends State<SaveTrialDialog> {
  bool _canSave = false;
  final _athleteController = TextEditingController();
  final _trialNameController = TextEditingController();

  @override
  void initState() {
    _athleteController.addListener(() {
      _canSave = _athleteController.text.isNotEmpty &&
          _trialNameController.text.isNotEmpty;
      setState(() {});
    });
    super.initState();
  }

  // The save trial dialog is in two parts. The first part is the name of the athlete that can be
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Texts.instance.saveTrial),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(Texts.instance.doYouWantToSaveThisTrial),
          const SizedBox(height: 10),
          RawAutocomplete<String>(
            textEditingController: _athleteController,
            focusNode: FocusNode(),
            optionsBuilder: (controller) => Athletes.instance.athleteNames
                .where((name) =>
                    name.toLowerCase().contains(controller.text.toLowerCase()))
                .toList(),
            fieldViewBuilder: (context, controller, node, onSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: node,
                onFieldSubmitted: (value) => onSubmitted(),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topCenter,
                child: Material(
                  elevation: 4.0,
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final name = options.elementAt(index);
                          return ListTile(
                            title: Text(name),
                            onTap: () {
                              onSelected(name);
                            },
                          );
                        }),
                  ),
                ),
              );
            },
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
        TextButton(
            onPressed: _canSave
                ? () {
                    // Print the selected athlete and trial names
                    debugPrint('Athlete: ${_athleteController.text}');
                  }
                : null,
            child: Text(Texts.instance.confirm)),
      ],
    );
  }
}
