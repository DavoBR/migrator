import 'package:migrator/models/models.dart';

const String APP_VERSION = 'debug';
const String REPOSITORY_URL =
    'https://api.github.com/repos/davobr/migrator/releases/latest';

const WARNING_ACTIONS = [
  MappingActionTaken.deleted,
  MappingActionTaken.updatedExisting,
];
