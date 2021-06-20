export 'constants.dart';
export 'crypto.dart';
export 'extensions.dart';
export 'http.dart';
export 'navigator.dart';
export 'snackbar.dart';
export 'dialogs.dart';
export 'utils.dart';
import 'dart:developer' as dev;

T parseEnum<T>(Iterable<T> values, String? value, {T orElse()?}) {
  return values.firstWhere(
    (type) => type.toString().split(".").last == value,
    orElse: orElse,
  );
}

void log(String message, {bool isError = false}) {
  // TODO guardar en un archivo usar el package:logging
  dev.log(message, level: isError ? 1000 : 800, name: 'MIGRATOR');
}

void logError(Object error, {String? message, StackTrace? stackTrace}) {
  // TODO guardar en un archivo usar el package:logging
  dev.log(
    message ?? error.toString(),
    error: error,
    stackTrace: stackTrace,
    level: 1000,
    name: 'MIGRATOR',
  );
}
