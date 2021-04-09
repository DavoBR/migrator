import 'package:flutter/material.dart';

import 'screens/select_connections_screen.dart';
import 'widgets/status_bar.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migrator v2.0',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        accentColor: Colors.green[600],
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      ),
      home: SafeArea(child: SelectConnectionsScreen()),
      builder: (context, widget) {
        return Container(
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: widget ?? Text("What the heck????"),
              ),
              StatusBar(),
            ],
          ),
        );
      },
    );
  }
}
