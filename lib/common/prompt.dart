import 'package:flutter/material.dart';

Future<T> prompt<T>(
  BuildContext context, {
  Widget title,
  Widget textOK,
  Widget textCancel,
  T initialValue,
  InputDecoration inputDecoration,
  int minLines = 1,
  int maxLines = 1,
  bool obscureText: false,
  TextInputType keyboardType = TextInputType.text,
  List<DropdownMenuItem<T>> items = const [],
}) {
  T value = initialValue;
  Widget content;

  if (items.isNotEmpty) {
    content = DropdownButtonFormField<T>(
      decoration: inputDecoration,
      value: initialValue,
      items: items,
      autofocus: true,
      onChanged: (item) => value = item,
    );
  } else {
    content = TextFormField(
      decoration: inputDecoration,
      keyboardType: keyboardType,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      autofocus: true,
      initialValue: initialValue as String,
      onChanged: (text) => value = text as T,
    );
  }

  return showDialog(
    context: context,
    builder: (_) => WillPopScope(
      child: AlertDialog(
        title: title ?? Text(''),
        content: content,
        actions: <Widget>[
          FlatButton(
              child: textCancel ?? Text('Cancelar'),
              onPressed: () => Navigator.pop(context, null)),
          FlatButton(
              child: textOK ?? Text('Aceptar'),
              onPressed: () => Navigator.pop(context, value)),
        ],
      ),
      onWillPop: () {
        Navigator.pop(context, null);
        return;
      },
    ),
  );
}
