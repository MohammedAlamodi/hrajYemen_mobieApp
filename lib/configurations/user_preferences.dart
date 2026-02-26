import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  SharedPreferences? prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    debugPrint("✅ init SharedPreferences");
  }

  Future<void> saveEncryptedString(
      {required String key, required String value}) async {
    final encryptedValue = await MyencryptDecryption.encryptAES(value);
    prefs!.setString(key, encryptedValue.base64);
  }

  // Get and decrypt a string
  Future<String?> getDecryptedString({required String key}) async {
    final encryptedString = prefs!.getString(key);
    if (encryptedString != null) {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedString);
      return await MyencryptDecryption.decryptAES(encrypted);
    }
    return null;
  }

  // Save an encrypted boolean value
  Future<void> saveBool({required String key, required bool value}) async {
    if( prefs == null){
      await init();
    }
    final encryptedValue =
    await MyencryptDecryption.encryptAES(value.toString());
    prefs!.setString(key, encryptedValue.base64);
  }

  // Get and decrypt a boolean value
  Future<bool> getBool({required String key, bool defaultValue = false}) async {
    if( prefs == null){
      await init();
    }

    final encryptedString = prefs!.getString(key);
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

  saveString({required String key, required String value}) {
    prefs!.setString(key, value);
  }

  Future<String> getString(
      {required String key, required String defaultValue}) async {
    if(prefs == null){
      await init();
    }
    return prefs!.getString(key) ?? defaultValue;
  }

  String getStringWhitOutInit(
      {required String key, required String defaultValue}) {

    return prefs!.getString(key) ?? defaultValue;
  }

  Future<void> logout(BuildContext context) async {
    await clearLogout(context);
    // String url = await UserPreferences().prefs!.getString(AppStrings.baseUrl) ?? '';
    Navigator.pushNamedAndRemoveUntil(
        context, LoginScreen.routeName, (route) => false
    );
  }

  Future<void> clearLogout(BuildContext context) async {
    prefs!.remove(AppStrings.cookie);
    prefs!.remove(AppStrings.languageKey);
    prefs!.remove(AppStrings.userNameKey);
    prefs!.remove(AppStrings.userIdKey);
    prefs!.remove(AppStrings.userEmailKey);
    prefs!.remove(AppStrings.refreshToken);
    prefs!.remove(AppStrings.loginTokenKey);

    // Provider.of<AddSellOrderViewModel>(context, listen: false).reset();
    //
    // Provider.of<AddProductsViewModel>(context, listen: false).reset();
  }
}
