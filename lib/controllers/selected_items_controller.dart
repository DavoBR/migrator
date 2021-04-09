import 'package:hooks_riverpod/hooks_riverpod.dart';

class SelectedItemsController extends StateNotifier<List<String>> {
  SelectedItemsController() : super([]);

  void clear() {
    state = [];
  }

  void select(String id) {
    if (state.contains(id)) return;

    state = state..add(id);
  }

  void unselect(String id) {
    if (!state.contains(id)) return;

    state = state..remove(id);
  }
}
