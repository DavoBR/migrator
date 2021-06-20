import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/version_check_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Migrator for CA API Gateway',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        buttonColor: Colors.green,
        accentColor: Colors.green[600],
        dividerColor: Color.fromRGBO(58, 66, 86, 1.0),
        backgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Colors.green,
        ),
      ),
      home: SafeArea(child: VersionCheckPage()),
    );
  }
}
