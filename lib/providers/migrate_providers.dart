import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';
import 'package:tuple/tuple.dart';

final migrateOutProvider = StateNotifierProvider(
  (ref) => MigrateOutController(ref.read),
);

final migrateOutItemFamily =
    FutureProvider.family<ItemWithId?, Tuple2<String, ItemType>>((
  ref,
  params,
) async {
  final items = ref.watch(migrateOutProvider.state).data?.value.items ?? [];
  final founds = items.where((item) => item.id == params.item1);

  if (founds.isNotEmpty) return founds.first;

  final item = ref.watch(itemFamily(params)).data?.value;

  return item;
});

final migratePassPhraseProvider = StateProvider<String?>((_) => null);

final itemMappingsFamily = Provider.family<List<ItemMapping>, bool>((
  ref,
  selectedsOrDependencies,
) {
  final mappings =
      ref.watch(migrateOutProvider.state).data?.value.mappings ?? [];
  final selecteds = ref.watch(selectedItemIdsProvider.state);

  return mappings
      .where((m) => selecteds.contains(m.srcId) == selectedsOrDependencies)
      .toList();
});

final mappingActionFamily = StateProvider.family<MappingAction, String>(
    (_, __) => MappingAction.ignore);

final mappingPropsFamily =
    StateProvider.family<Map<String, Object>, String>((_, __) => {});

final cwpValueFamily = StateProvider.family<String?, String>((_, __) => null);

final migrateInProvider = StateNotifierProvider(
  (ref) => MigrateInController(ref.read),
);

final mappingResultFamily = Provider.family<ItemMapping?, String>((
  ref,
  itemId,
) {
  final mappings =
      ref.watch(migrateInProvider.state).data?.value.mappings ?? [];

  final founds = mappings.where((m) => m.srcId == itemId);

  return founds.isNotEmpty ? founds.first : null;
});

enum MigrateResultType { none, test, live }

final migrateResultTypeProvider =
    StateProvider<MigrateResultType>((_) => MigrateResultType.none);
