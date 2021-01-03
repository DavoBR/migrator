import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:migrator/services/restman_service.dart';
import 'package:migrator/models/models.dart';

part 'connections_store.g.dart';

class ConnectionsStore = _ConnectionsStoreBase with _$ConnectionsStore;

abstract class _ConnectionsStoreBase with Store {
  final _restman = GetIt.I<RestmanService>();
  final _prefs = GetIt.I<SharedPreferences>();

  _ConnectionsStoreBase() {
    final json = jsonDecode(_prefs.getString('connections') ?? '[]');
    connections.addAll(List.of(json).map((json) => Connection.fromJson(json)));
  }

  @observable
  ObservableList<Connection> connections = ObservableList<Connection>();

  @observable
  Connection selected;

  @observable
  ObservableFuture testFuture;

  @action
  void select(Connection connection) {
    if (selected == connection) return;
    selected = connection;
    testFuture = null;
  }

  @action
  void save(Connection connection) {
    if (selected == null) {
      connections.add(connection);
    } else {
      final index = connections.indexOf(selected);
      if (index > -1) {
        connections[index] = connection;
        selected = connection;
      }
    }

    _persist();
  }

  @action
  void remove(Connection connection) {
    connections.remove(connection);

    _persist();
  }

  void _persist() {
    _prefs.setString('connections', jsonEncode(connections));
  }

  void test(Connection connection) {
    testFuture = ObservableFuture(_restman.test(connection));
  }
}
