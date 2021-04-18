import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/repositories/repositories.dart';

final selectedConnectionProvider = StateProvider<Connection?>((_) => null);

final connectionRepositoryProvider = Provider((ref) => ConnectionRepository());

final connectionTestProvider =
    StateNotifierProvider((ref) => ConnectionTestController(ref.read));

final connectionListProvider =
    StateNotifierProvider((ref) => ConnectionListController(ref.read));

final connectionListFamily =
    Provider.family<AsyncValue<List<Connection>>, bool>((ref, isSource) {
  final asyncList = ref.watch(connectionListProvider.state);

  if (isSource) return asyncList;

  final src = ref.watch(sourceConnectionProvider).state;

  return asyncList.whenData(
    (list) => src != null ? list.where((c) => c.id != src.id).toList() : [],
  );
});

final sourceConnectionProvider = StateProvider<Connection?>((_) => null);

final targetConnectionProvider = StateProvider<Connection?>((_) => null);
