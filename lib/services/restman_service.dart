import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:migrator/common/common.dart';
import 'package:migrator/models/models.dart';
import 'package:xml/xml.dart';

class RestmanService {
  RestmanService({this.useCache = false});

  final bool useCache;

  Future<List<Item>> fetchItems(Connection connection, ItemType type,
      {String parentFolderId}) async {
    final resource = ItemConstant.of(type).resource;
    final cacheKey =
        resource + (parentFolderId != null ? '_$parentFolderId' : '');

    String xml = await _fromCache(connection, cacheKey);

    if (xml == null) {
      xml = await _request(connection, 'GET', '/restman/1.0/$resource',
          params: {'parentFolder.id': parentFolderId});

      await _toCache(connection, cacheKey, xml);
    }

    return ItemFactory.listFromXml(xml);
  }

  Future<BundleItem> migrateOut(
    Connection connection, {
    List<String> services = const [],
    List<String> policies = const [],
    List<String> folders = const [],
    String keyPassPhrase,
  }) async {
    final resource = 'bundle';
    final cacheKey = 'migrateout';
    String xml = await _fromCache(connection, cacheKey);

    if (xml == null) {
      xml = await _request(
        connection,
        'GET',
        '/restman/1.0/$resource',
        params: {
          'service': services,
          'policy': policies,
          'folder': folders,
          'encryptSecrets': 'true',
          'encassAsPolicyDependency': 'true',
        },
        headers: {'L7-key-passphrase': keyPassPhrase},
      );

      await _toCache(connection, cacheKey, xml);
    }

    return ItemFactory.fromXml<BundleItem>(xml);
  }

  Future<BundleMappingsItem> migrateIn(
    Connection connection,
    String bundle, {
    String keyPassPhrase,
    bool test: true,
  }) async {
    final resource = 'bundle';
    final cacheKey = 'migratein${(test ? '_test' : '')}';
    String xml = await _fromCache(connection, cacheKey);

    if (xml == null) {
      xml = await _request(
        connection,
        'PUT',
        '/restman/1.0/$resource',
        xml: bundle,
        params: {'test': test.toString()},
        headers: {'L7-key-passphrase': keyPassPhrase},
      );

      await _toCache(connection, cacheKey, xml);
    }

    return ItemFactory.fromXml<BundleMappingsItem>(xml);
  }

  Future<File> _cacheFile(Connection connection, String resource) async {
    var cacheFileName = [
          connection.host.replaceAll(RegExp(r'[\.:]'), '_'),
          resource,
        ].where((x) => x.isNotEmpty).join('_').toLowerCase() +
        '.xml';

    final appDirPath = await getApplicationSupportDirectory();
    final cacheDirPath = join(appDirPath.path, 'cache');
    await Directory(cacheDirPath).create(recursive: true);
    final cacheFile = File(join(cacheDirPath, cacheFileName));

    return cacheFile;
  }

  Future<String> _fromCache(Connection connection, String resource) async {
    if (!useCache) return null;

    final cacheFile = await _cacheFile(connection, resource);

    if (await cacheFile.exists()) {
      await Future.delayed(Duration(seconds: 2));
      return await cacheFile.readAsString();
    }

    return null;
  }

  Future<void> _toCache(
      Connection connection, String resource, String xml) async {
    if (!useCache) return null;

    final cacheFile = await _cacheFile(connection, resource);

    await cacheFile.writeAsString(xml);
  }

  Future<void> test(Connection connection) async {
    final response = await http(
      'GET',
      'https://${connection.host}/restman/1.0/doc/home.html',
      username: connection.username,
      password: connection.password,
      certificate: connection.certificate,
    );

    switch (response.statusCode) {
      case 200:
        return;
      case 401:
        throw Failure('Credenciales no validas');
      default:
        throw Failure('Ha ocurrido un error estableciendo la conexión');
    }
  }

  Future<String> _request(Connection connection, String method, String path,
      {Map<String, dynamic> params,
      Map<String, String> headers,
      String xml}) async {
    if (path != null && !path.startsWith('/')) {
      path = '/$path';
    }

    final url = 'https://${connection.host}$path';

    final response = await http(method, url,
        headers: headers,
        params: params,
        body: xml,
        contentType: 'application/xml',
        username: connection.username,
        password: connection.password,
        certificate: connection.certificate);

    final result = await response.transform(utf8.decoder).join();

    if (response.statusCode == 500) {
      var errorMessage = response.reasonPhrase;
      try {
        final policyResult = XmlDocument.parse(result)
            .findAllElements('l7:policyResult')
            .first
            .text;
        if (policyResult != null) {
          errorMessage = policyResult;
        }
      } catch (_) {}

      throw Failure(errorMessage);
    }

    return result;
  }
}
