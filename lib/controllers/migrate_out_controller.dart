import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';
import 'package:migrator/services/services.dart';

import 'status_controller.dart';

class MigrateOutController extends StateNotifier<AsyncValue<BundleItem>> {
  Reader _read;

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

  MigrateOutController(this._read) : super(AsyncValue.loading());

  Future<void> migrateOut() async {
    state = AsyncValue.loading();
    _status.setStatus(
      'Descargando bundle de los objetos selecionados...',
      progress: true,
    );

    final selectedItems = _read(selectedItemsProvider);
    final serviceItems = selectedItems.where((i) => i.type == ItemType.service);
    final policyItems = selectedItems.where((i) => i.type == ItemType.policy);
    final keyPassPhrase = base64.encode(utf8.encode(Uuid().v4()));

    _read(migratePassPhraseProvider).state = keyPassPhrase;

    try {
      final bundle = await _restman.migrateOut(
        _connection,
        services: serviceItems.map((e) => e.id).toList(),
        policies: policyItems.map((e) => e.id).toList(),
        keyPassPhrase: keyPassPhrase,
      );

      if (bundle == null) throw Exception('bundle is null');

      await _setCustomMappings(bundle);

      state = AsyncValue.data(bundle);
      _status.setStatus(
        'Descarga del bundle completada, proceder con la prueba del despliegue',
        icon: Icons.check,
      );
    } on Exception catch (error, st) {
      state = AsyncValue.error(error, st);
      _status.setError('Error descargando el bundle ', error, stackTrace: st);
    }
  }

  Future<void> _setCustomMappings(BundleItem bundle) async {
    final selectedIds = _read(selectedItemIdsProvider.state);
    for (var mapping in bundle.mappings) {
      var action = mapping.action;
      final props = Map<String, Object>();

      if (selectedIds.contains(mapping.srcId)) {
        // marcar los objetos selecionados para crear o actualizar
        action = MappingAction.newOrUpdate;
      } else {
        switch (mapping.type) {
          case ItemType.folder:
          case ItemType.clusterProperty:
          case ItemType.jdbcConnection:
          case ItemType.ssgActiveConnector:
            // marcar para crear o usar existente si es un FOLDER, CWP o CONEXION (BD, MQ, ACTIVE DIRECTORY)
            action = MappingAction.newOrExisting;
            break;
          default:
            action = MappingAction.ignore;
        }
      }

      //print('srcId: ${mapping.srcId}: ${mapping.action} => $action');

      switch (mapping.type) {
        case ItemType.service:
          // mapear servicios por url y no por id, para evitar duplicación
          props['MapBy'] = 'routingUri';
          break;
        case ItemType.policy:
          // mapear politicas por gui y no por id, para evitar duplicación
          props['MapBy'] = 'gui';
          break;
        case ItemType.folder:
          // mapear las carpetas por ruta para mantener homologación entre ambientes
          props['MapBy'] = 'path';
          props['MapTo'] = await _buildFolderPath(mapping.srcId);
          break;
        default:
          // cual otra cosa mapear por el nombre (CWP, CONEXIONES MQ, BD, ACTIVE DIRECTORY, etc..)
          props['MapBy'] = 'name';
          break;
      }

      _read(mappingActionFamily(mapping.srcId)).state = action;
      _read(mappingPropsFamily(mapping.srcId)).state = props;
    }
  }

  Future<String> _buildFolderPath(String itemId) async {
    final pathParts = [];
    var item = await _read(itemFamily(Tuple2(itemId, ItemType.folder)).future)
        as FolderItem?;

    while (item != null && item.folderId.isNotEmpty) {
      pathParts.add(item.name);
      item = await _read(
        itemFamily(Tuple2(item.folderId, ItemType.folder)).future,
      ) as FolderItem?;
    }

    final path = '/${pathParts.reversed.join('/')}';

    return path;
  }
}
