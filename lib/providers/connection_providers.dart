import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/repositories/repositories.dart';

final selectedConnectionProvider = StateProvider<Connection?>((_) => null);

final connectionRepositoryProvider = Provider((ref) => ConnectionRepository());

final connectionTestProvider =
    Provider((ref) => ConnectionTestController(ref.read));

final connectionListProvider =
    StateNotifierProvider((ref) => ConnectionListController(ref.read));

final sourceConnectionProvider = StateProvider<Connection?>((_) => null);

final targetConnectionProvider = StateProvider<Connection?>((_) => null);
