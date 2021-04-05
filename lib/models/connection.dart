import 'dart:convert';
import 'dart:typed_data';

import 'package:migrator/common/crypto.dart';

class Connection {
  String name;
  String host;
  String username;
  String password;
  Uint8List? certificate;

  Connection({
    required this.name,
    required this.host,
    this.username = '',
    this.password = '',
    this.certificate,
  });

  Connection.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        host = json['host'] ?? '',
        username = json['username'] ?? '',
        password = decrypt(json['password'], orElse: (_) => ''),
        certificate = (json['certificate'] ?? '').isNotEmpty
            ? base64Decode(json['certificate'])
            : null;

  Map<String, dynamic> toJson() => {
        'name': name,
        'host': host,
        'username': username,
        'password': encrypt(password, orElse: (_) => ''),
        'certificate': certificate != null ? base64Encode(certificate!) : null,
      };

  @override
  String toString() {
    return '$name [$host]';
  }
}
