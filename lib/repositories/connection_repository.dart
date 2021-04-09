import 'dart:convert';

import 'package:migrator/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ConnectionRepository {
  Future<List<Connection>> fetchList() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonDecode(prefs.getString('connections') ?? '[]');
    final list =
        List.of(json).map((json) => Connection.fromJson(json)).toList();

    await _migrate(list);

    return list;
  }

  Future<void> _migrate(List<Connection> list) async {
    if (!list.any((c) => c.id.isEmpty)) return;

    list.forEach((c) {
      if (c.id.isEmpty) {
        c.id = Uuid().v4();
      }
    });

    _saveList(list);
  }

  Future<void> _saveList(List<Connection> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('connections', jsonEncode(list));
  }

  Future<void> create(Connection connection) async {
    connection.id = Uuid().v4();
    final connections = await fetchList();
    await _saveList([...connections, connection]);
  }

  Future<void> update(Connection target) async {
    final connections = await fetchList();
    await _saveList(connections
        .map((connection) => connection.id == target.id ? target : connection)
        .toList());
  }

  Future<void> delete(Connection target) async {
    final connections = await fetchList();
    await _saveList(
      connections.where((connection) => connection.id != target.id).toList(),
    );
  }
}
