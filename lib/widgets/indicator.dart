import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../common/extensions.dart';

class Indicator extends StatelessWidget {
  Indicator(
    this.content, {
    Key key,
    this.icon,
    this.size,
    this.color,
    this.alignment,
  }) : super(key: key);

  final Text content;
  final IconData icon;
  final double size;
  final Color color;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).primaryIconTheme.color;
    final size = this.size ?? 24.0;
    return Row(
      mainAxisAlignment: alignment ?? MainAxisAlignment.start,
      children: [
        icon != null
            ? Icon(icon, color: color, size: size)
            : SpinKitCircle(color: color, size: size).sizedBox(height: size),
        SizedBox(width: 5.0),
        content,
      ],
    );
  }
}
