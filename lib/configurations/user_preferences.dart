import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/screens/admin_web/login/web_admin_login_screen.dart';
import '../presentation/screens/common/auth/login/login_view.dart';
import '../presentation/screens/common/common_view_model.dart';
import 'data/api_services.dart';
import 'encryption_decryption.dart';
import 'resources/strings_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  Future<void> saveEncryptedString({
    required String key,
    required String value,
  }) async {
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
    if (prefs == null) {
      await init();
    }
    final encryptedValue = await MyencryptDecryption.encryptAES(
      value.toString(),
    );
    prefs!.setString(key, encryptedValue.base64);
  }

  // Get and decrypt a boolean value
  Future<bool> getBool({required String key, bool defaultValue = false}) async {
    if (prefs == null) {
      await init();
    }

    final encryptedString = prefs!.getString(key);
    if (encryptedString != null) {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedString);
      debugPrint("encrypted '}");
      debugPrint("encrypted $encrypted'}");
      final decryptedString = await MyencryptDecryption.decryptAES(encrypted);
      debugPrint(
        "decryptedString $decryptedString, ${decryptedString == 'true'}",
      );
      return decryptedString == 'true';
    }
    return defaultValue;
  }

  saveString({required String key, required String value}) {
    prefs!.setString(key, value);
  }

  Future<String> getString({
    required String key,
    required String defaultValue,
  }) async {
    if (prefs == null) {
      await init();
    }
    return prefs!.getString(key) ?? defaultValue;
  }

  String getStringWhitOutInit({
    required String key,
    required String defaultValue,
  }) {
    return prefs!.getString(key) ?? defaultValue;
  }

  Future<void> logout(BuildContext context) async {
    await clearLogout(context);

    kIsWeb
        ? Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const WebAdminLoginScreen(),
            ),
            (route) => false,
          )
        : Navigator.pushNamedAndRemoveUntil(
            context,
            LoginScreen.routeName,
            (route) => false,
          );
  }

  Future<void> clearLogout(BuildContext context) async {
    if (prefs == null) {
      await init();
    }

    // 1. حذف كل البيانات المخزّنة الخاصة بالمستخدم من الجهاز
    //    (نُبقي فقط على لغة التطبيق لأنها تفضيل عام وليست بيانات مستخدم).
    await prefs!.remove(AppStrings.cookie);
    await prefs!.remove(AppStrings.userNameKey);
    await prefs!.remove(AppStrings.userIdKey);
    await prefs!.remove(AppStrings.userEmailKey);
    await prefs!.remove(AppStrings.userProfileImageUrlKey);
    await prefs!.remove(AppStrings.userTypeKey);
    await prefs!.remove(AppStrings.refreshToken);
    await prefs!.remove(AppStrings.loginTokenKey);

    // 2. تصفير التوكن المحفوظ في الذاكرة (RAM) داخل طبقة الشبكة
    AppStrings.staticToken = '';
    ApiService().token = null;

    // 3. تسجيل الخروج من Firebase (يستخدمه الشات) لمنع بقاء جلسة قديمة
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Firebase signOut error (ignored): $e");
    }

    // 4. تصفير حالة المستخدم في الذاكرة حتى تختفي صفحات الشات/البروفايل فوراً
    try {
      Provider.of<CommonViewModel>(context, listen: false).clearUserSession();
    } catch (e) {
      debugPrint("clearUserSession error (ignored): $e");
    }
  }
}
