import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:migrator/utils/utils.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:migrator/providers/common_providers.dart';

class StatusBar extends HookWidget {
  StatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = useProvider(statusProvider.state);

    final widgets = [];

    if (status != null) {
      if (status.icon != null) {
        widgets.add(status.icon);
        widgets.add(SizedBox(width: 5.0));
      }

      widgets.add(Text(status.text));

      if (status.more != null && status.more!.isNotEmpty) {
        widgets.add(SizedBox(width: 5.0));
        widgets.add(TextButton(
          onPressed: () => alert(
            context,
            title: Text(status.text),
            content: Text(status.more!),
          ),
          child: Text('Ver mas').italic().textColor(Colors.red),
        ));
      }
    }

    return DefaultTextStyle(
      style: TextStyle(color: Colors.white),
      child: Container(
        height: 30.0,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        color: Colors.transparent,
        child: Row(children: [...widgets]),
      ),
    );
  }
}
