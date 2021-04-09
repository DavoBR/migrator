import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/models/connection.dart';
import 'package:migrator/providers/providers.dart';

class ConnectionTestController {
  final Reader _read;

  ConnectionTestController(this._read);

  Future<void> test(Connection connection) async {
    final status = _read(statusProvider);

    try {
      status.setStatus(
        'Probando conexión a ${connection.toString()}...',
        progress: true,
      );

      await Future.delayed(Duration(seconds: 2));

      await _read(restmanServiceProvider).test(connection);

      status.setStatus(
        'Conexión establecida a ${connection.toString()}',
        icon: Icons.check,
      );
    } on Exception catch (error, stackTrace) {
      status.setError(
        'Conexión no establecida a ${connection.toString()}',
        error,
        stackTrace: stackTrace,
      );
    }
  }
}
