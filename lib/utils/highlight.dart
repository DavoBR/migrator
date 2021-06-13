import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

Future<void> showHighlight({
  required Widget title,
  required String code,
  String language = 'plaintext',
}) async {
  final primaryColor = Get.theme.primaryColor;

  await Get.dialog(
    AlertDialog(
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
        TextButton.icon(
          icon: Icon(Icons.copy, color: primaryColor, size: 16.0),
          label: Text('Copiar').textColor(primaryColor),
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
        ),
        TextButton.icon(
          icon: Icon(Icons.close, color: primaryColor, size: 16.0),
          label: Text('Cerrar').textColor(primaryColor),
          onPressed: () => Get.back(),
        )
      ],
    ),
    barrierDismissible: true,
  );
}
