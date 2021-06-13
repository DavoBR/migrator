import 'package:flutter/material.dart';

class Case extends StatelessWidget {
  final List<When> children;

  Case({required this.children});

  @override
  Widget build(BuildContext context) {
    return children.firstWhere(
      (child) => child.test,
      orElse: () => Otherwise((_) => SizedBox.shrink()),
    );
  }
}

class When extends StatelessWidget {
  final bool test;
  final Widget Function(BuildContext context) builder;

  When(this.test, this.builder);

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

class Otherwise extends When {
  Otherwise(Widget Function(BuildContext context) builder)
      : super(true, builder);
}
