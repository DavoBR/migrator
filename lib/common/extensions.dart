import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:recase/recase.dart';
import 'package:provider/provider.dart';

extension AsyncSnapshotX<T> on AsyncSnapshot<T> {
  bool isWaiting() => this.connectionState == ConnectionState.waiting;
  bool isDone() => this.connectionState == ConnectionState.done;
  bool isActive() => this.connectionState == ConnectionState.active;
  bool isNone() => this.connectionState == ConnectionState.none;

  R when<R>({
    required R waiting(),
    required R data(T),
    required R error(dynamic error),
    R none()?,
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

extension BuildContextX on BuildContext {
  T store<T extends Store>() {
    return Provider.of<T>(this, listen: false);
  }
}

extension ObservableFutureX<T> on ObservableFuture<T> {
  bool isPending() => this.status == FutureStatus.pending;
  bool isFulfilled() => this.status == FutureStatus.fulfilled;
  bool isRejected() => this.status == FutureStatus.rejected;
  bool isCompleted() => this.isFulfilled() || this.isRejected();

  R when<R>({
    required R pending(),
    required R fulfilled(T),
    required R rejected(dynamic error),
  }) {
    switch (this.status) {
      case FutureStatus.pending:
        return pending();
      case FutureStatus.fulfilled:
        return fulfilled(this.value);
      case FutureStatus.rejected:
        return rejected(this.error);
    }
  }
}

extension FutureX<T> on Future<T> {
  Future<R> when<R>({
    required R done(T),
    required R error(T),
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
  V? get(K key, {V orElse()?}) {
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
