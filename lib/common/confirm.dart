import 'package:flutter/material.dart';

Future<bool> confirm(
  BuildContext context, {
  Widget? title,
  required Widget content,
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
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
    ),
  );

  return result ?? false;
}
