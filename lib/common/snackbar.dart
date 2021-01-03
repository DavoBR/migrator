import 'package:flutter/material.dart';

Function showSnackBar(BuildContext context, SnackBar snackBar) {
  final ctrl = ScaffoldMessenger.of(context).showSnackBar(snackBar);

  return () => ctrl.close();
}
