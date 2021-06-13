import 'package:get/get.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/repositories/repositories.dart';

class ConnectionsSelectionController extends GetxController {
  final _repo = Get.put(ConnectionRepository());

  final source = Connection.empty().obs;
  final target = Connection.empty().obs;

  int get connectionsCount => _repo.connections.length;

  List<Connection> get sourceConnectionList =>
      _repo.connections.where((conn) => conn.id != target.value.id).toList();
  List<Connection> get targetConnectionList =>
      _repo.connections.where((conn) => conn.id != source.value.id).toList();

  void selectSource(Connection connection) {
    source.value = connection;
  }

  void selectTarget(Connection connection) {
    target.value = connection;
  }

  void reset() {
    source.value = Connection.empty();
    target.value = Connection.empty();
  }
}
