import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/controllers/controllers.dart';

final statusProvider = StateNotifierProvider((ref) => StatusController());
