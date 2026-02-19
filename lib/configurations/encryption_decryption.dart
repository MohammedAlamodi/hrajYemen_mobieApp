import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyencryptDecryption {
  static const _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'encryption_key';
  static const _ivStorageKey = 'encryption_iv';

  static Future<encrypt.Key> _getKey() async {
    final keyString = await _storage.read(key: _keyStorageKey);
    if (keyString != null) {
      return encrypt.Key.fromBase16(keyString);
    } else {
      final newKey = encrypt.Key.fromLength(32);
      await _storage.write(key: _keyStorageKey, value: newKey.base16);
      return newKey;
    }
  }

  static Future<encrypt.IV> _getIV() async {
    final ivString = await _storage.read(key: _ivStorageKey);
    if (ivString != null) {
      return encrypt.IV.fromBase16(ivString);
    } else {
      final newIV = encrypt.IV.fromLength(16);
      await _storage.write(key: _ivStorageKey, value: newIV.base16);
      return newIV;
    }
  }

  static Future<encrypt.Encrypted> encryptAES(String text) async {
    final key = await _getKey();
    final iv = await _getIV();
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted;
  }

  static Future<String> decryptAES(encrypt.Encrypted text) async {
    final key = await _getKey();
    final iv = await _getIV();
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt(text, iv: iv);
    return decrypted;
  }
}
