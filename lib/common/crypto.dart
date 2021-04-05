import 'package:encrypt/encrypt.dart';

const pwd = 'rmmMqZ9FUPAzNa6QDs26FmAuz384QcCn';
final key = Key.fromUtf8(pwd);
final iv = IV.fromLength(16);
final encrypter = Encrypter(AES(key));

String? encrypt(String plainText, {String orElse(Object error)?}) {
  try {
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  } catch (err) {
    if (orElse == null) throw err;

    return orElse(err);
  }
}

String decrypt(String encoded, {String orElse(Object error)?}) {
  try {
    final decrypted = encrypter.decrypt64(encoded, iv: iv);

    return decrypted;
  } catch (err) {
    if (orElse == null) throw err;

    return orElse(err);
  }
}
