import 'package:flutter/material.dart';
import 'package:migrator/repositories/connection_repository.dart';
import 'package:migrator/utils/storages.dart';

import 'app.dart';

void main() async {
  await Storages.init();
  await ConnectionRepository.migrate();
  runApp(App());
}
