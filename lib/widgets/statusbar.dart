import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  StatusBar({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.white),
      child: Container(
        height: 30.0,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: child,
      ),
    );
  }
}
