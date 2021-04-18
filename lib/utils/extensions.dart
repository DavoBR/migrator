import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

extension AsyncSnapshotX<T> on AsyncSnapshot<T> {
  bool isWaiting() => this.connectionState == ConnectionState.waiting;
  bool isDone() => this.connectionState == ConnectionState.done;
  bool isActive() => this.connectionState == ConnectionState.active;
  bool isNone() => this.connectionState == ConnectionState.none;

  R when<R>({
    required R Function() waiting,
    required R Function(T?) data,
    required R Function(dynamic error) error,
    R Function()? none,
  }) {
    if (this.isDone()) {
      return this.hasError ? error(this.error) : data(this.data);
    }

    if (this.isNone()) {
      return none != null ? none() : data(null);
    }

    return waiting();
  }
}

extension FutureX<T> on Future<T> {
  Future<R> when<R>({
    required R Function(T) done,
    required R Function(T) error,
  }) {
    return this.then((value) => done(value), onError: (err) => error(err));
  }
}

extension StringX on String {
  String toCamelCase() => ReCase(this).camelCase;
  String toConstantCase() => ReCase(this).constantCase;
  String toDotCase() => ReCase(this).dotCase;
  String toHeaderCase() => ReCase(this).headerCase;
  String toParamCase() => ReCase(this).paramCase;
  String toPascalCase() => ReCase(this).pascalCase;
  String toPathCase() => ReCase(this).pathCase;
  String toSentenceCase() => ReCase(this).sentenceCase;
  String toSnakeCase() => ReCase(this).snakeCase;
  String toTitleCase() => ReCase(this).titleCase;
}

extension MapX<K, V> on Map<K, V> {
  V? get(K key, {V? Function()? orElse}) {
    if (key != null && this.containsKey(key)) {
      return this[key];
    } else if (orElse != null) {
      return orElse();
    } else {
      return null;
    }
  }
}

extension ListX<T> on List<T> {
  List<T> sortBy<R>(Comparable Function(T) field) {
    this.sort((a, b) => field(a).compareTo(field(b)));
    return this;
  }

  List<R> distinct<R>(R Function(T) field) {
    return this.map((e) => field(e)).toSet().toList();
  }
}

extension WidgetX on Widget {
  Widget sizedBox({double? width, double? height}) {
    return SizedBox(
      width: width,
      height: height,
      child: this,
    );
  }
}
