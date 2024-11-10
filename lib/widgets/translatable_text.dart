import 'package:flight_time/models/text_manager.dart';
import 'package:flutter/material.dart';

class TranslatableText extends StatefulWidget {
  const TranslatableText(this.text, {super.key, this.textAlign, this.style});

  final TranslatableString text;
  final TextAlign? textAlign;
  final TextStyle? style;

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  @override
  void initState() {
    super.initState();
    TextManager.instance.onLanguageChanged.addListener(_update);
  }

  @override
  void dispose() {
    TextManager.instance.onLanguageChanged.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.text.value, style: widget.style);
  }
}
