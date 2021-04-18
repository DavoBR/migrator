import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/models/connection.dart';
import 'package:migrator/providers/providers.dart';

class ConnectionTestController extends StateNotifier<AsyncValue<bool>> {
  final Reader _read;

  ConnectionTestController(this._read) : super(AsyncValue.data(false));

  Future<void> test(Connection connection) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await Future.delayed(Duration(seconds: 2));
      await _read(restmanServiceProvider).test(connection);
      return true;
    });
  }

  void clear() {
    state = AsyncValue.data(false);
  }
}
