import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/models/connection.dart';
import 'package:migrator/providers/providers.dart';

class ConnectionTestController {
  final Reader _read;

  ConnectionTestController(this._read);

  Future<void> test(Connection connection) async {
    await Future.delayed(Duration(seconds: 2));

    await _read(restmanServiceProvider).test(connection);
  }
}
