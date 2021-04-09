import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';
import 'package:migrator/services/restman_service.dart';

import 'status_controller.dart';

class ItemListController extends StateNotifier<AsyncValue<List<ItemInFolder>>> {
  final Reader _read;

  StatusController get _status => _read(statusProvider);

  RestmanService get _restman => _read(restmanServiceProvider);

  Connection get _connection {
    final connection = _read(sourceConnectionProvider).state;

    if (connection == null) {
      final error = Exception('No se ha selecionado una conexión origen');
      state = AsyncValue.error(error);
      throw error;
    }

    return connection;
  }

  ItemListController(this._read) : super(AsyncValue.loading());

  Future<void> fetchRootItems() async {
    _status.setStatus('Descargando objetos...', progress: true);

    try {
      final folders = await _restman
          .fetchItems(
            _connection,
            ItemType.folder,
            parentFolderId: '',
          )
          .then((l) => l.cast<ItemInFolder>());

      state = AsyncValue.data(folders);

      await fetchItems(folders.first.id);
    } finally {
      _status.reset();
    }
  }

  Future<void> fetchItems(String folderId) async {
    state.whenData((items) async {
      try {
        _status.setStatus('Descargando objetos...', progress: true);

        final types = [ItemType.folder, ItemType.service, ItemType.policy];
        final futures = types.map(
          (type) => _restman
              .fetchItems(
                _connection,
                type,
                parentFolderId: folderId,
              )
              .then((l) => l.cast<ItemInFolder>()),
        );
        final folderItems = await Future.wait(futures);

        state = AsyncValue.data(
          items..addAll(folderItems.expand((l) => l.sortBy((i) => i.name))),
        );

        _status.reset();
      } on Exception catch (error, st) {
        _status.setError(
          'Error descargando los objetos',
          error,
          stackTrace: st,
        );
      }
    });
  }
}
