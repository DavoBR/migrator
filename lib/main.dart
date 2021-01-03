import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:migrator/app.dart';
import 'package:migrator/services/restman_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setup();
  runApp(App());
}

void setup() {
  GetIt.I.registerSingleton<RestmanService>(RestmanService(useCache: false));
  GetIt.I.registerSingletonAsync(() => SharedPreferences.getInstance());
}
