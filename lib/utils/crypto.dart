import 'package:encrypt/encrypt.dart';

const pwd = 'rmmMqZ9FUPAzNa6QDs26FmAuz384QcCn';
final key = Key.fromUtf8(pwd);
final iv = IV.fromLength(16);
final encrypter = Encrypter(AES(key));

String? encrypt(String plainText, {throwError: true}) {
  try {
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  } catch (err) {
    if (throwError) {
      throw err;
    }
  }

  return null;
}

String? decrypt(String encoded, {throwError: true}) {
  try {
    final decrypted = encrypter.decrypt64(encoded, iv: iv);

    return decrypted;
  } catch (err) {
    if (throwError) {
      throw err;
    }
  }

  return null;
}
