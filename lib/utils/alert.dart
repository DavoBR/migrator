import 'package:flutter/material.dart';

Future<void> alert(
  BuildContext context, {
  required Widget title,
  required Widget content,
  String textOk = 'Aceptar',
}) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        TextButton(
          child: Text(textOk),
          onPressed: () => Navigator.pop(context, null),
        ),
      ],
    ),
  );
}
