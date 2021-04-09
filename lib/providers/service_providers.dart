import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/services/restman_service.dart';

final restmanServiceProvider = Provider((ref) => RestmanService());
