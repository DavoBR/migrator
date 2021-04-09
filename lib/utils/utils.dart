export 'alert.dart';
export 'confirm.dart';
export 'crypto.dart';
export 'extensions.dart';
export 'highlight.dart';
export 'http.dart';
export 'navigator.dart';
export 'prompt.dart';
export 'snackbar.dart';
export 'utils.dart';

T parseEnum<T>(Iterable<T> values, String? value, {T orElse()?}) {
  return values.firstWhere(
    (type) => type.toString().split(".").last == value,
    orElse: orElse,
  );
}
