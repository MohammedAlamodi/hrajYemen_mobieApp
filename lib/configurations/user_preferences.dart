import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/screens/common/auth/login/login_view.dart';
import 'encryption_decryption.dart';
import 'resources/strings_manager.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._const();
  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._const();

  late final SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveEncryptedString(
      {required String key, required String value}) async {
    final encryptedValue = await MyencryptDecryption.encryptAES(value);
    prefs.setString(key, encryptedValue.base64);
  }

  // Get and decrypt a string
  Future<String?> getDecryptedString({required String key}) async {
    final encryptedString = prefs.getString(key);
    if (encryptedString != null) {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedString);
      return await MyencryptDecryption.decryptAES(encrypted);
    }
    return null;
  }

  // Save an encrypted boolean value
  Future<void> saveBool({required String key, required bool value}) async {
    final encryptedValue =
    await MyencryptDecryption.encryptAES(value.toString());
    prefs.setString(key, encryptedValue.base64);
  }

  // Get and decrypt a boolean value
  Future<bool> getBool({required String key, bool defaultValue = false}) async {
    final encryptedString = prefs.getString(key);
    if (encryptedString != null) {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedString);
      debugPrint("encrypted '}");
      debugPrint("encrypted $encrypted'}");
      final decryptedString = await MyencryptDecryption.decryptAES(encrypted);
      debugPrint(
          "decryptedString $decryptedString, ${decryptedString == 'true'}");
      return decryptedString == 'true';
    }
    return defaultValue;
  }

  void saveString({required String key, required String value}) {
    prefs.setString(key, value);
  }
  // void saveString({required String key, required String value}) {
  //   prefs.setString(key, value);
  // }

  String getString(
      {required String key, required String defaultValue}) {
    return prefs.getString(key) ?? defaultValue;
  }
  // String? getString({required String key}) {
  //   return prefs.getString(key);
  // }

  Future<String>? get type => (prefs.getString('type') != null)
      ? MyencryptDecryption.decryptAES(
      encrypt.Encrypted.fromBase64(prefs.getString('type')!))
      : null;
  Future<String>? get refreshToken => (prefs.getString('refreshToken') != null)
      ? MyencryptDecryption.decryptAES(
      encrypt.Encrypted.fromBase64(prefs.getString('refreshToken')!))
      : null;
  String? get userToken => prefs.getString("userToken");

  void deleteUser() {
    prefs.remove("userId");
    prefs.remove("userAdminID");
    prefs.remove("firstName");
    prefs.remove("lastName");
    prefs.remove("phone");
    prefs.remove("type");
    prefs.remove("userToken");
    prefs.remove("refreshToken");
  }

  Future<void> logout(BuildContext context) async {
    await clearLogout(context);
    Navigator.pushNamedAndRemoveUntil(
        context, LoginScreen.routeName, (route) => false);
  }

  Future<void> clearLogout(BuildContext context) async {
    prefs.remove(AppStrings.cookie);
    prefs.remove(AppStrings.loginTokenKey);

  }
// bool isLogin() {
//   var token = prefs.getString("access_token");
//   return token != null || token!.isNotEmpty;
// }
}

// saveString({required String key, required String value}) async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   sharedPreferences.setString(key, value);
// }

// Future<String> getString(
//     {required String key, required String defaultValue}) async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   debugPrint('value');
//   return sharedPreferences.getString(key) ?? defaultValue;
// }
