import 'package:flutter/material.dart';

Future<bool> confirm<T>(
  BuildContext context, {
  required Widget content,
  Widget title = const Text(''),
  Widget textOK = const Text('Si'),
  Widget textCancel = const Text('No'),
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => WillPopScope(
      child: AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          TextButton(
              child: textCancel,
              onPressed: () => Navigator.pop(context, false)),
          TextButton(
              child: textOK, onPressed: () => Navigator.pop(context, true)),
        ],
      ),
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
    ),
  );

  return result ?? false;
}
