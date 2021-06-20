import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recase/recase.dart';

extension AsyncSnapshotX<T> on AsyncSnapshot<T> {
  R when<R>({
    required R Function() waiting,
    required R Function(T?) data,
    required R Function(dynamic error, StackTrace? stackTrace) error,
  }) {
    if (hasError) {
      return error(error, stackTrace);
    } else if (hasData) {
      return data(this.data);
    } else {
      return waiting();
    }
  }
}

extension FutureX<T> on Future<T> {
  FutureBuilder<T> when({
    required Widget Function() waiting,
    required Widget Function(T?) data,
    required Widget Function(dynamic error, StackTrace? stackTrace) error,
    T? initialData,
  }) {
    return FutureBuilder<T>(
      future: this,
      initialData: initialData,
      builder: (_, snapshot) => snapshot.when(
        waiting: waiting,
        data: data,
        error: error,
      ),
    );
  }
}

extension StreamX<T> on Stream<T> {
  StreamBuilder<T> when({
    required Widget Function() waiting,
    required Widget Function(T?) data,
    required Widget Function(dynamic error, StackTrace? stackTrace) error,
    T? initialData,
  }) {
    return StreamBuilder<T>(
      stream: this,
      initialData: initialData,
      builder: (_, snapshot) => snapshot.when(
        waiting: waiting,
        data: data,
        error: error,
      ),
    );
  }
}

extension RxStatusX<T> on RxStatus {
  R when<R>({
    required R Function() success,
    required R Function() loading,
    required R Function(String? error) error,
    R Function()? loadingMore,
  }) {
    if (isLoadingMore && loadingMore != null) {
      return loadingMore();
    } else if (isSuccess) {
      return success();
    } else if (isError) {
      return error(errorMessage);
    } else {
      return loading();
    }
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
