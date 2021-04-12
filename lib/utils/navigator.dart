import 'package:flutter/material.dart';

Future<T?> push<T extends Object>(
  BuildContext context,
  WidgetBuilder builder, {
  Object? arguments,
  bool fullscreenDialog = false,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute<T>(
      builder: builder,
      fullscreenDialog: fullscreenDialog,
      settings: RouteSettings(arguments: arguments),
    ),
  );
}

Future<T?> navigate<T extends Object>(
  BuildContext context,
  WidgetBuilder builder, {
  Object? arguments,
  bool fullscreenDialog = false,
  bool replace = false,
}) {
  final route = MaterialPageRoute<T>(
    builder: builder,
    fullscreenDialog: fullscreenDialog,
    settings: RouteSettings(arguments: arguments),
  );

  if (replace) {
    return Navigator.pushReplacement(context, route);
  }

  return Navigator.push(context, route);
}
