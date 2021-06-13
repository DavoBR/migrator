import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> alert({
  required String title,
  Widget content = const SizedBox.shrink(),
  String textConfirm = 'Aceptar',
}) async {
  await Get.defaultDialog(
    title: title,
    content: content,
    textConfirm: textConfirm,
    onConfirm: () => Get.back(),
  );
}

Future<bool> confirm({
  required String title,
  Widget? content,
  String textConfirm = 'Si',
  String textCancel = 'No',
  void Function()? onConfirm,
  void Function()? onCancel,
}) async {
  final result = await Get.defaultDialog<bool>(
    title: title,
    content: content,
    textConfirm: textConfirm,
    textCancel: textCancel,
    onConfirm: () {
      Get.back(result: true);
      if (onConfirm != null) onConfirm();
    },
    onCancel: () {
      Get.back(result: false);
      if (onCancel != null) onCancel();
    },
  );

  return result ?? false;
}

Future<T?> prompt<T>({
  String title = '',
  String textConfirm = 'Aceptar',
  String textCancel = 'Cancelar',
  T? initialValue,
  InputDecoration? inputDecoration,
  int minLines = 1,
  int maxLines = 1,
  bool obscureText: false,
  TextInputType keyboardType = TextInputType.text,
  List<DropdownMenuItem<T>> items = const [],
  void Function(T? value)? onConfirm,
  void Function()? onCancel,
}) async {
  T? value = initialValue;
  Widget content;

  if (items.isNotEmpty) {
    content = DropdownButtonFormField<T>(
      decoration: inputDecoration,
      value: initialValue,
      items: items,
      autofocus: true,
      onChanged: (item) => value = item,
    );
  } else {
    content = TextFormField(
      decoration: inputDecoration,
      keyboardType: keyboardType,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      autofocus: true,
      initialValue: initialValue?.toString(),
      onChanged: (text) => value = text as T,
    );
  }

  return await Get.defaultDialog<T>(
    title: title,
    content: content,
    textConfirm: textConfirm,
    textCancel: textCancel,
    onConfirm: () {
      Get.back(result: value);
      if (onConfirm != null) onConfirm(value);
    },
    onCancel: () {
      if (onCancel != null) onCancel();
    },
  );
}
