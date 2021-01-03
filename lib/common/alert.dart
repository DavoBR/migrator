import 'package:flutter/material.dart';

Future<String> alert(
  BuildContext context, {
  Widget title,
  Widget content,
  String textOk = 'Aceptar',
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        FlatButton(
          child: Text(textOk),
          onPressed: () => Navigator.pop(context, null),
        ),
      ],
    ),
  );
}
