import 'package:mobx/mobx.dart';

import 'package:migrator/models/models.dart';

part 'selected_connections_store.g.dart';

class SelectedConnectionsStore = _SelectedConnectionsStoreBase
    with _$SelectedConnectionsStore;

abstract class _SelectedConnectionsStoreBase with Store {
  @observable
  Connection sourceConnection;

  @observable
  Connection targetConnection;
}
