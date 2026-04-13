import 'package:flutter/material.dart';
import '../../../../../configurations/user_preferences.dart'; // مسار ملف التفضيلات الخاص بك
import '../../../../../configurations/resources/strings_manager.dart'; // مسار ثوابت النصوص
import '../main_screen/admin_main_screen.dart';
import 'web_admin_login_screen.dart';


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // التحقق هل يوجد Token أو بيانات مستخدم محفوظة في المتصفح
    String token = await UserPreferences().getString(key: AppStrings.loginTokenKey, defaultValue: '');

    setState(() {
      _isLoggedIn = token.isNotEmpty; // إذا كان هناك توكن، إذن هو مسجل دخول
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // التوجيه الذكي
    return _isLoggedIn ? const AdminMainScreen() : const WebAdminLoginScreen();
  }
}