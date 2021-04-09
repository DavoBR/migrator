import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:migrator/providers/providers.dart';

import 'status_controller.dart';

class SelectedItemsController extends StateNotifier<List<String>> {
  final Reader _read;

  StatusController get _status => _read(statusProvider);

  SelectedItemsController(this._read) : super([]);

  void select(String id) {
    if (state.contains(id)) return;

    state = state..add(id);

    _status.setStatus('Proceder con la descarga del bundle', icon: Icons.info);
  }

  void unselect(String id) {
    if (!state.contains(id)) return;

    state = state..remove(id);

    if (state.isEmpty) {
      _status.reset();
    }
  }
}
