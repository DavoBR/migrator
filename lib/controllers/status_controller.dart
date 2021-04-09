import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/status_message.dart';

class StatusController extends StateNotifier<StatusMessage?> {
  StatusController() : super(null);

  void reset() {
    state = null;
  }

  void setStatus(
    String text, {
    IconData? icon,
    Color iconColor = Colors.green,
    bool progress: false,
    String? more,
  }) {
    Widget iconWidget;
    if (progress) {
      iconWidget = CircularProgressIndicator(backgroundColor: iconColor)
          .sizedBox(height: 16.0, width: 16.0);
    } else {
      iconWidget = Icon(icon, color: iconColor, size: 24);
    }
    state = StatusMessage(text: text, icon: iconWidget, more: more);
  }

  void setError(String text, Exception ex, {StackTrace? stackTrace}) {
    setStatus(
      text,
      icon: Icons.error,
      more: '${ex.toString()}\n\n${stackTrace.toString()}',
    );
  }
}
