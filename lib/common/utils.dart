T parseEnum<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split(".").last == value,
      orElse: () => null);
}

class Failure {
  Failure(this.message);

  String message;

  @override
  String toString() => message;
}
