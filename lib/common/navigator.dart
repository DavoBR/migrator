import 'package:flutter/material.dart';

Future<T> push<T extends Object>(
  BuildContext context,
  WidgetBuilder builder, {
  Object arguments,
  bool fullscreenDialog,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute<T>(
      builder: builder,
      fullscreenDialog: fullscreenDialog ?? false,
      settings: RouteSettings(arguments: arguments),
    ),
  );
}
