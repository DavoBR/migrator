import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/providers/providers.dart';

class SelectedConnectionsBar extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final sourceConnection = useProvider(sourceConnectionProvider).state;
    final targetConnection = useProvider(targetConnectionProvider).state;
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(sourceConnection.toString()),
          const SizedBox(width: 5.0),
          const Icon(Icons.arrow_forward, color: Colors.green),
          const SizedBox(width: 5.0),
          Text(targetConnection.toString()),
        ],
      ),
    );
  }
}
