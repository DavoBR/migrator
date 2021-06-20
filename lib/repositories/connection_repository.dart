import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/utils/storages.dart';
import 'package:migrator/utils/utils.dart';

class ConnectionRepository {
  final connections = List<Connection>.empty().obs;

  ConnectionRepository() {
    _load();
  }

  void _load() {
    final List<Connection> list = [];
    Storages.connections
        .getValues()
        .forEach((map) => list.add(Connection.fromJson(map)));

    connections.value = list;
  }

  static Future<void> migrate() async {
    var keys = Storages.connections.getKeys();
    if (keys.isNotEmpty) return;

    try {
      // migrate from SharedPrefs (v1.1.1)
      final prefs = await SharedPreferences.getInstance();
      final list = List.of(jsonDecode(prefs.getString('connections') ?? '[]'))
          .map((data) => Connection.fromJson(data));

      // asign connection id (v1.0.1)
      list.where((c) => c.id.isEmpty).forEach((c) => c.id = Uuid().v4());

      // save in new storage
      list.forEach((c) async {
        await Storages.connections.write(c.id, c.toJson());
      });
    } catch (error, st) {
      logError(error, stackTrace: st, message: 'Error migrando conexiones');
    }
  }

  void save(Connection connection) {
    if (connection.id.isEmpty) {
      connection.id = Uuid().v4();
    }

    Storages.connections.write(connection.id, connection.toJson());

    _load();
  }

  void delete(Connection connection) {
    Storages.connections.remove(connection.id);

    _load();
  }
}
