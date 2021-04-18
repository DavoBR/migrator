import 'dart:convert';
import 'dart:typed_data';

import 'package:migrator/utils/crypto.dart';

class Connection {
  String id;
  String name;
  String host;
  String? username;
  String? password;
  Uint8List? certificate;

  Connection({
    required this.id,
    required this.name,
    required this.host,
    this.username,
    this.password,
    this.certificate,
  });

  Connection.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['name'],
        host = json['host'],
        username = json['username'],
        password = decrypt(json['password'], throwError: false),
        certificate = (json['certificate'] ?? '').isNotEmpty
            ? base64Decode(json['certificate'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'username': username,
        'password':
            password != null ? encrypt(password!, throwError: false) : null,
        'certificate': certificate != null ? base64Encode(certificate!) : null,
      };

  @override
  String toString() {
    return '$name [$host]';
  }
}
