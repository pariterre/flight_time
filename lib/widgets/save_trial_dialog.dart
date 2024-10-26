import 'package:flight_time/models/athletes.dart';
import 'package:flight_time/texts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String _lastAthlete = '';

class SaveTrialDialog extends StatefulWidget {
  const SaveTrialDialog({super.key});

  @override
  State<SaveTrialDialog> createState() => _SaveTrialDialogState();
}

class _SaveTrialDialogState extends State<SaveTrialDialog> {
  bool _canSave = false;

  final _nameFocusNode = FocusNode();
  final _athleteController = TextEditingController(text: _lastAthlete);

  final String _trialPrefix =
      DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
  late final _trialNameController = TextEditingController(text: _trialPrefix);
  final _trialFocusNode = FocusNode();

  @override
  void initState() {
    _athleteController.addListener(() {
      _updateCanSave();
    });

    _trialNameController.addListener(() {
      _updateCanSave();
    });
    _trialFocusNode.addListener(() {
      if (_trialFocusNode.hasFocus) {
        _trialNameController.selection = TextSelection.fromPosition(
          TextPosition(
              offset:
                  _trialNameController.text.length), // Keep cursor at the end
        );
      }
    });

    super.initState();
  }

  void _updateCanSave() {
    _canSave = _athleteController.text.isNotEmpty &&
        _trialNameController.text.isNotEmpty;
    setState(() {});
  }

  // The save trial dialog is in two parts. The first part is the name of the athlete that can be
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Texts.instance.saveTrial),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RawAutocomplete<String>(
            textEditingController: _athleteController,
            focusNode: _nameFocusNode,
            optionsBuilder: (controller) => Athletes.instance.athleteNames
                .where((name) =>
                    name.toLowerCase().contains(controller.text.toLowerCase()))
                .toList(),
            fieldViewBuilder: (context, controller, node, onSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: node,
                onFieldSubmitted: (value) => onSubmitted(),
                decoration: InputDecoration(
                  labelText: Texts.instance.athleteName,
                ),
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
          TextFormField(
            controller: _trialNameController,
            focusNode: _trialFocusNode,
            decoration: InputDecoration(
              labelText: Texts.instance.trialName,
            ),
            // Prevent user from editing the prefix
            onChanged: (value) {
              if (!value.startsWith(_trialPrefix)) {
                _trialNameController.text =
                    _trialPrefix; // Ensure the prefix is kept
                _trialNameController.selection = TextSelection.fromPosition(
                  TextPosition(
                      offset: _trialNameController
                          .text.length), // Keep cursor at the end
                );
              } else if (value == '${_trialPrefix}_') {
                _trialNameController.text = _trialPrefix;
                _trialNameController.selection = TextSelection.fromPosition(
                  TextPosition(
                      offset: _trialNameController
                          .text.length), // Keep cursor at the end
                );
              } else if (!value.startsWith('${_trialPrefix}_')) {
                final suffix = value.substring(_trialPrefix.length);
                _trialNameController.text = '${_trialPrefix}_$suffix';
                _trialNameController.selection = TextSelection.fromPosition(
                  TextPosition(
                      offset: _trialNameController
                          .text.length), // Keep cursor at the end
                );
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Texts.instance.cancel),
        ),
        TextButton(
            onPressed: _canSave
                ? () {
                    _lastAthlete = _athleteController.text;
                    Navigator.of(context).pop({
                      'athlete': _athleteController.text,
                      'trial': '${_trialNameController.text}.mp4'
                    });
                  }
                : null,
            child: Text(Texts.instance.confirm)),
      ],
    );
  }
}