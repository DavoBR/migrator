import 'package:get/get.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/repositories/repositories.dart';
import 'package:migrator/services/services.dart';

class ConnectionsEditController extends GetxController {
  final _repo = Get.put(ConnectionRepository());
  final _restman = Get.put(RestmanService());

  final selected = Connection.empty().obs;
  final testing = Future.value(false).obs;

  List<Connection> get connections => _repo.connections;

  void select(Connection connection) {
    selected.value = connection;
    testing.value = Future.value(false);
  }

  void save(Connection connection) {
    _repo.save(connection);

    selected.value = connection;
    testing.value = Future.value(false);
  }

  void delete(Connection connection) {
    _repo.delete(connection);

    if (selected.value.id == connection.id) {
      selected.value = Connection.empty();
    }

    testing.value = Future.value(false);
  }

  void test(Connection connection) {
    testing.value = Future.delayed(Duration(seconds: 2))
        .then((_) => _restman.test(connection))
        .then((_) => true);
  }
}
