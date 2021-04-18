import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/models/models.dart';
import 'package:tuple/tuple.dart';

import 'connection_providers.dart';
import 'service_providers.dart';

final itemListProvider = StateNotifierProvider(
  (ref) => ItemListController(ref.read),
);

final itemFamily =
    FutureProvider.family<ItemWithId?, Tuple2<String, ItemType>>((
  ref,
  params,
) async {
  final items = ref.watch(itemListProvider.state).data?.value ?? [];
  final founds = items.where((item) => item.id == params.item1);

  if (founds.isNotEmpty) return founds.first;

  final restman = ref.watch(restmanServiceProvider);
  final connection = ref.watch(sourceConnectionProvider).state;

  if (connection == null) return null;

  return restman.fetchItemById(connection, params.item2, params.item1);
});

final rootFolderIdProvider = Provider<String?>((ref) {
  final items = ref.watch(itemListProvider.state).data?.value ?? [];
  final founds =
      items.where((i) => i.folderId == '' && i.type == ItemType.folder);
  return founds.isNotEmpty ? founds.first.id : null;
});

final folderItemsFamily = Provider.family<List<ItemInFolder>, String?>((
  ref,
  folderId,
) {
  final items = ref.watch(itemListProvider.state).data?.value ?? [];

  return items.where((item) => item.folderId == folderId).toList();
});

final selectedItemIdsProvider = StateNotifierProvider(
  (_) => SelectedItemsController(),
);

final selectedItemsProvider = Provider<List<ItemInFolder>>((ref) {
  final itemIds = ref.watch(selectedItemIdsProvider.state);
  final items = ref.watch(itemListProvider.state).data?.value ?? [];

  return items.where((item) => itemIds.contains(item.id)).toList();
});

final folderIsLoadingFamily =
    StateProvider.family<bool, String>((_, __) => false);
