import 'package:flutter/foundation.dart';
import 'package:migrator/models/item_mapping.dart';

class MappingConfig {
  MappingConfig({
    @required this.action,
    this.properties = const {},
  });

  final MappingAction action;
  final Map<String, Object> properties;
}
