import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';
import 'package:migrator/services/restman_service.dart';

class ItemListController extends StateNotifier<AsyncValue<List<ItemInFolder>>> {
  final Reader _read;

  RestmanService get _restman => _read(restmanServiceProvider);

  Connection get _connection {
    final connection = _read(sourceConnectionProvider).state;

    if (connection == null) {
      final error = Exception('No se ha selecionado una conexión origen');
      state = AsyncValue.error(error);
      throw error;
    }

    return connection;
  }

  ItemListController(this._read) : super(AsyncValue.loading());

  void clear() {
    state = AsyncValue.data([]);
  }

  Future<void> fetchRootItems() async {
    try {
      state = AsyncValue.loading();

      await Future.delayed(Duration(seconds: 10));

      final folders = await _restman
          .fetchItems(
            _connection,
            ItemType.folder,
            parentFolderId: '',
          )
          .then((l) => l.cast<ItemInFolder>());
      await _fetchItems(folders, folders.first.id);
    } on Exception catch (error, st) {
      state = AsyncValue.error(error, st);
    }
  }

  void fetchItems(String folderId) {
    state.whenData((oldList) => _fetchItems(oldList, folderId));
  }

  Future<void> _fetchItems(List<ItemInFolder> oldList, String folderId) async {
    final folderIsLoading = _read(folderIsLoadingFamily(folderId));
    try {
      folderIsLoading.state = true;

      final types = [ItemType.folder, ItemType.service, ItemType.policy];
      final futures = types.map(
        (type) => _restman
            .fetchItems(
              _connection,
              type,
              parentFolderId: folderId,
            )
            .then((l) => l.cast<ItemInFolder>()),
      );
      final folderItems = await Future.wait(futures);

      state = AsyncValue.data(
        oldList..addAll(folderItems.expand((l) => l.sortBy((i) => i.name))),
      );
    } finally {
      folderIsLoading.state = false;
    }
  }
}
