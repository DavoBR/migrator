import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormBuilderFileField extends StatelessWidget {
  const FormBuilderFileField({
    Key key,
    this.attribute,
    this.validators,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.filter,
    this.defaultFilterIndex,
    this.defaultExtension,
    this.dialogTitle,
    this.onChanged,
    this.textBuilder,
  }) : super(key: key);

  final String attribute;
  final List<FormFieldValidator> validators;
  final Uint8List initialValue;
  final InputDecoration decoration;
  final Map<String, String> filter;
  final int defaultFilterIndex;
  final String defaultExtension;
  final String dialogTitle;
  final ValueChanged<File> onChanged;
  final Widget Function(Uint8List file) textBuilder;

  @override
  Widget build(BuildContext context) {
    return FormBuilderCustomField<Uint8List>(
      attribute: attribute,
      validators: validators ?? [],
      initialValue: initialValue,
      formField: FormField(
        enabled: true,
        builder: (field) {
          return GestureDetector(
            child: InputDecorator(
              decoration: decoration.copyWith(
                labelText: decoration.labelText ?? 'Seleccionar un archivo',
                errorText: decoration.errorText,
                labelStyle: TextStyle(
                  fontSize: 16.0,
                ),
                suffixIcon: AnimatedOpacity(
                  duration: Duration(milliseconds: 400),
                  opacity: field.value == null ? 0.0 : 1.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    child: Icon(Icons.clear),
                    onTap: field.value == null ? null : field.reset,
                  ),
                ),
              ),
              child: textBuilder != null
                  ? textBuilder(field?.value)
                  : Text(field?.value != null ? 'Cambiar archivo' : ''),
            ),
            onTap: () async {
              final filePicker = OpenFilePicker()
                ..filterSpecification = filter
                ..defaultFilterIndex = defaultFilterIndex ?? 0
                ..defaultExtension = defaultExtension
                ..title = dialogTitle ?? 'Seleccionar un archivo';

              final file = filePicker.getFile();

              if (file != null) {
                field.didChange(await file.readAsBytes());
                if (onChanged != null) onChanged(file);
              }
            },
          );
        },
      ),
    );
  }
}
