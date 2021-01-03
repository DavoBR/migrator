import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/common.dart';
import 'stores/stores.dart';
import 'screens/select_connections_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SelectedConnectionsStore>(
          create: (_) => SelectedConnectionsStore(),
        ),
        Provider<ConnectionsStore>(create: (_) => ConnectionsStore()),
        Provider<ItemsStore>(
          create: (context) => ItemsStore(
            context.store<SelectedConnectionsStore>(),
          ),
        ),
        Provider<MigrateStore>(
          create: (context) => MigrateStore(
            context.store<SelectedConnectionsStore>(),
            context.store<ItemsStore>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Migrator v2.0',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.green,
          accentColor: Colors.green[600],
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        ),
        home: SafeArea(child: SelectConnectionsScreen()),
      ),
    );
  }
}
