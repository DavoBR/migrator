import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ActionButton extends StatelessWidget {
  ActionButton({required this.icon, required this.label, this.onPressed});

  final IconData icon;
  final String label;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon).iconColor(Colors.white).semanticsLabel(label),
      label: Text(label).textColor(Colors.white),
      onPressed: onPressed,
    );
  }
}
