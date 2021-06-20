import 'package:get_storage/get_storage.dart';

class Storages {
  static late GetStorage _connections;

  static GetStorage get connections => _connections;

  static Future<void> init() async {
    final appSupportDir = await getApplicationSupportDirectory();

    _connections = GetStorage('connections', appSupportDir.path);
    await _connections.initStorage;
  }
}
