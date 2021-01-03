import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ActionButton extends StatelessWidget {
  ActionButton({this.icon, this.label, this.onPressed});

  final IconData icon;
  final String label;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      icon: Icon(icon).iconColor(Colors.white).semanticsLabel(label),
      label: Text(label).textColor(Colors.white),
      onPressed: onPressed,
    );
  }
}
