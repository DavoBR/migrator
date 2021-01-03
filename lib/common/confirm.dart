import 'package:flutter/material.dart';

Future<T> confirm<T>(
  BuildContext context, {
  Widget title,
  Widget content,
  Widget textOK,
  Widget textCancel,
}) {
  return showDialog(
    context: context,
    builder: (_) => WillPopScope(
      child: AlertDialog(
        title: title ?? Text(''),
        content: content,
        actions: <Widget>[
          FlatButton(
              child: textCancel ?? Text('No'),
              onPressed: () => Navigator.pop(context, false)),
          FlatButton(
              child: textOK ?? Text('Si'),
              onPressed: () => Navigator.pop(context, true)),
        ],
      ),
      onWillPop: () {
        Navigator.pop(context, false);
        return;
      },
    ),
  );
}
