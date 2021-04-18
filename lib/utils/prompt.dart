import 'package:flutter/material.dart';

Future<T?> prompt<T>(
  BuildContext context, {
  Widget title = const Text(''),
  Widget textOK = const Text('Aceptar'),
  Widget textCancel = const Text('Cancelar'),
  T? initialValue,
  InputDecoration? inputDecoration,
  int minLines = 1,
  int maxLines = 1,
  bool obscureText: false,
  TextInputType keyboardType = TextInputType.text,
  List<DropdownMenuItem<T>> items = const [],
}) async {
  T? value = initialValue;
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
      initialValue: initialValue?.toString(),
      onChanged: (text) => value = text as T,
    );
  }

  var result = await showDialog<T>(
    context: context,
    builder: (_) => WillPopScope(
      child: AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          TextButton(
            child: textCancel,
            onPressed: () => Navigator.pop(context, null),
          ),
          TextButton(
            child: textOK,
            onPressed: () => Navigator.pop(context, value),
          ),
        ],
      ),
      onWillPop: () {
        Navigator.pop(context, null);
        return Future.value(false);
      },
    ),
  );

  return result;
}
