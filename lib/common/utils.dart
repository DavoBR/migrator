T parseEnum<T>(Iterable<T> values, String value, {T orElse()?}) {
  return values.firstWhere(
    (type) => type.toString().split(".").last == value,
    orElse: orElse,
  );
}

class Failure {
  Failure(this.message);

  String message;

  @override
  String toString() => message;
}
