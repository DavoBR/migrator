import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';

class RestmanService extends GetxService {
  RestmanService({this.useCache = false});

  final bool useCache;

  Future<List<T>> fetchItems<T extends Item>(
    Connection connection, {
    String? parentFolderId,
  }) async {
    final resource = ItemConstant.ofType<T>().resource;
    final cacheKey =
        resource + (parentFolderId != null ? '_$parentFolderId' : '');

    String? xml = await _fromCache(connection, cacheKey, () async {
      return await _request(
        connection,
        'GET',
        '/restman/1.0/$resource',
        params: {'parentFolder.id': parentFolderId},
      );
    });

    return ItemFactory.listFromXml<T>(xml);
  }

  Future<T> fetchItemById<T extends ItemWithId>(
    Connection connection,
    String id,
  ) async {
    final resource = ItemConstant.ofType<T>().resource;
    final cacheKey = '${resource}_$id';
    final xml = await _fromCache(connection, cacheKey, () async {
      return await _request(
        connection,
        'GET',
        '/restman/1.0/$resource/$id',
      );
    });

    return ItemFactory.fromXml<T>(xml);
  }

  Future<BundleItem> migrateOut(
    Connection connection, {
    List<String> services = const [],
    List<String> policies = const [],
    List<String> folders = const [],
    String? keyPassPhrase,
  }) async {
    final resource = 'bundle';
    final cacheKey = 'migrateout';
    final xml = await _fromCache(connection, cacheKey, () async {
      return await _request(
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
    });

    return ItemFactory.fromXml<BundleItem>(xml);
  }

  Future<BundleMappingsItem> migrateIn(
    Connection connection,
    String bundle, {
    String? keyPassPhrase,
    bool test: true,
    String versionComment = '',
  }) async {
    final resource = 'bundle';
    final cacheKey = 'migratein${(test ? '_test' : '')}';
    String xml = await _fromCache(connection, cacheKey, () async {
      return await _request(
        connection,
        'PUT',
        '/restman/1.0/$resource',
        xml: bundle,
        params: {
          'test': test.toString(),
          'versionComment': versionComment,
        },
        headers: {'L7-key-passphrase': keyPassPhrase},
      );
    });

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

  Future<String> _fromCache(
    Connection connection,
    String resource,
    Future<String> Function() valueFactory,
  ) async {
    if (!useCache) return await valueFactory();

    final cacheFile = await _cacheFile(connection, resource);

    if (await cacheFile.exists()) {
      await Future.delayed(Duration(seconds: 2));
      return await cacheFile.readAsString();
    } else {
      final value = await valueFactory();

      final cacheFile = await _cacheFile(connection, resource);
      await cacheFile.writeAsString(value);

      return value;
    }
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
        throw Exception('Credenciales no validas');
      default:
        throw Exception('Ha ocurrido un error estableciendo la conexión');
    }
  }

  Future<String> _request(
    Connection connection,
    String method,
    String path, {
    Map<String, dynamic> params = const {},
    Map<String, String?> headers = const {},
    String? xml,
  }) async {
    if (!path.startsWith('/')) path = '/$path';

    final url = 'https://${connection.host}$path';

    final response = await http(
      method,
      url,
      headers: headers,
      params: params,
      body: xml,
      contentType: 'application/xml',
      username: connection.username,
      password: connection.password,
      certificate: connection.certificate,
    );

    final result = await response.transform(utf8.decoder).join();

    if (response.statusCode == 500) {
      var errorMessage = response.reasonPhrase;
      try {
        final policyResult =
            XmlDocument.parse(result).findAllElements('l7:policyResult').first;

        final status = policyResult.getAttribute('status');

        if (status != null && status.isNotEmpty) {
          errorMessage += ' / $status';
        }

        if (policyResult.text.isNotEmpty) {
          errorMessage += ' / ${policyResult.text}';
        }
      } catch (_) {}

      throw Exception(errorMessage);
    }

    return result;
  }
}
