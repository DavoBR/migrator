import 'package:flutter/material.dart';

import 'screens/check_version_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migrator for CA API Gateway',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        buttonColor: Colors.green,
        accentColor: Colors.green[600],
        dividerColor: Color.fromRGBO(58, 66, 86, 1.0),
        backgroundColor: Colors.white,
      ),
      home: SafeArea(child: CheckVersionScreen()),
    );
  }
}
