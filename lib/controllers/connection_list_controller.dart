import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/providers/providers.dart';
import 'package:migrator/providers/connection_providers.dart';
import 'package:migrator/models/connection.dart';

import 'status_controller.dart';

class ConnectionListController
    extends StateNotifier<AsyncValue<List<Connection>>> {
  final Reader _read;

  StatusController get _status => _read(statusProvider);

  ConnectionListController(this._read) : super(AsyncValue.loading());

  Future<void> fetch() async {
    _status.setStatus('Cargando las conexiones...', progress: true);
    state = AsyncValue.loading();

    try {
      final connections = await _read(connectionRepositoryProvider).fetchList();
      _status.reset();

      state = AsyncValue.data(connections);
    } on Exception catch (error, stackTrace) {
      _status.setError(
        'No se pudo cargar las conexiones',
        error,
        stackTrace: stackTrace,
      );

      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> add(Connection connection) async {
    try {
      await _read(connectionRepositoryProvider).create(connection);

      state.whenData((connections) {
        state = AsyncValue.data(connections..add(connection));
      });
    } on Exception catch (error, stackTrace) {
      _status.setError(
        'No se pudo crear la conexión',
        error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> update(Connection target) async {
    try {
      await _read(connectionRepositoryProvider).update(target);

      state.whenData((connections) {
        state = AsyncValue.data(connections
            .map((connection) =>
                connection.id == target.id ? target : connection)
            .toList());
      });
    } on Exception catch (error, stackTrace) {
      _status.setError(
        'No se pudo actualizar los datos de la conexión',
        error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> delete(Connection target) async {
    try {
      await _read(connectionRepositoryProvider).delete(target);

      state.whenData((connections) {
        state = AsyncValue.data(connections
            .where((connection) => connection.id != target.id)
            .toList());
      });
    } on Exception catch (error, stackTrace) {
      _status.setError(
        'No se pudo eliminar la conexión',
        error,
        stackTrace: stackTrace,
      );
    }
  }
}
