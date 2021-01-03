import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:styled_widget/styled_widget.dart';

Future<String> showHighlight(
  BuildContext context, {
  Widget title,
  String code,
  String language = 'plaintext',
}) {
  final primaryColor = Theme.of(context).primaryColor;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      title: title,
      titlePadding: const EdgeInsets.all(4),
      contentPadding: const EdgeInsets.all(0),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: HighlightView(
          code,
          language: language,
          theme: githubTheme,
          padding: EdgeInsets.all(12),
          textStyle: TextStyle(
            fontFamily:
                'SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace',
            fontSize: 12,
          ),
        ),
      ),
      actions: [
        FlatButton.icon(
          icon: Icon(Icons.copy, color: primaryColor, size: 16.0),
          label: Text('Copiar').textColor(primaryColor),
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
        ),
        FlatButton.icon(
          icon: Icon(Icons.close, color: primaryColor, size: 16.0),
          label: Text('Cerrar').textColor(primaryColor),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ),
  );
}
