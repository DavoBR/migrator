import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/providers/providers.dart';
import 'package:migrator/providers/connection_providers.dart';
import 'package:migrator/models/connection.dart';

class ConnectionListController
    extends StateNotifier<AsyncValue<List<Connection>>> {
  final Reader _read;

  ConnectionListController(this._read) : super(AsyncValue.loading());

  Future<void> fetch() async {
    state = AsyncValue.loading();

    try {
      final connections = await _read(connectionRepositoryProvider).fetchList();
      state = AsyncValue.data(connections);
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> add(Connection connection) async {
    await _read(connectionRepositoryProvider).create(connection);

    state.whenData((connections) {
      state = AsyncValue.data(connections..add(connection));
    });
  }

  Future<void> update(Connection target) async {
    await _read(connectionRepositoryProvider).update(target);

    state.whenData((connections) {
      state = AsyncValue.data(connections
          .map((connection) => connection.id == target.id ? target : connection)
          .toList());
    });
  }

  Future<void> delete(Connection target) async {
    await _read(connectionRepositoryProvider).delete(target);

    state.whenData((connections) {
      state = AsyncValue.data(connections
          .where((connection) => connection.id != target.id)
          .toList());
    });
  }
}
