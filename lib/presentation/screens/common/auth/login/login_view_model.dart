import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/presentation/screens/common/common_view_model.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../../../configurations/resources/strings_manager.dart';
import '../../../../../configurations/user_preferences.dart';
import '../../../../../model/login_model.dart';
import '../../../../custom_widgets/dialog/error_dialog.dart';
import '../../../../custom_widgets/dialog/overlay_helper.dart';
import '../../../home/main_wrapper_screen.dart';
import 'login_view_rep.dart';
import 'package:dio/dio.dart';

class LoginViewModel extends ChangeNotifier {
  var email = '';
  var userName = '';
  var password = '';

  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  final LoginViewRepository _repo = LoginViewRepository();

  String? errorEmail;
  String? errorPass;
  bool rememberMyLogin = false;
  bool obscureText = true;
  late CommonViewModel commonViewModel;

  setDataWithNull() {
    password = '';
    userName = '';
    searchController = TextEditingController();
    _isLoading = false;

    notifyListeners();
  }

  bool validate(context) {
    bool isValid = true;

    if (userName.isEmpty) {
      errorEmail = S.of(context)!.requiredFiled;
      isValid = false;
    }

    if (password.isEmpty) {
      errorPass = S.of(context)!.requiredFiled;
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  // دالة تسجيل الدخول
  // Future<bool> loginApp(BuildContext context) async {
  //   // 1. التحقق من الحقول
  //   bool val = validate(context);
  //
  //   if(val) {
  //     // 2. تفعيل حالة التحميل
  //     _isLoading = true;
  //     notifyListeners();
  //
  //     try {
  //       // 3. استدعاء الـ API
  //       final tokens = await _repo.login(
  //         email.trim(),
  //         password.trim(),
  //       );
  //
  //       // 4. في حال النجاح: حفظ التوكنز
  //       await _saveTokensLocally(tokens.data.accessToken, tokens.refreshToken);
  //
  //       // هنا يمكنك تحديث توكن الـ ApiService إذا كان يقبله ديناميكياً
  //       // ApiService.token = tokens.accessToken;
  //
  //       _isLoading = false;
  //       notifyListeners();
  //       return true; // نجاح العملية
  //
  //     } catch (e) {
  //       // 5. في حال الفشل: التقاط الخطأ وعرضه
  //       _isLoading = false;
  //       _errorMessage = e.toString().replaceAll('Exception: ', '');
  //       notifyListeners();
  //
  //       // إظهار سناك بار بالخطأ
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(_errorMessage!),
  //             backgroundColor: Colors.red,
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //       }
  //       return false;
  //     }
  //   }
  //   return false;
  // }
  //
  // // دالة مساعدة لحفظ التوكن في الجهاز
  // Future<void> _saveTokensLocally(String access, String refresh) async {
  //   await UserPreferences().saveString(key: AppStrings.loginTokenKey, value: access);
  //   await UserPreferences().saveString(key: AppStrings.refreshToken, value: refresh);
  // }

  @override
  void dispose() {
    email = '';
    password = '';
    super.dispose();
  }

  // دالة تسجيل الدخول
  void onLoginClick(BuildContext context) async {
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    
    _isLoading = true;
    notifyListeners();

    LoginResponseModel? apiResponse;

    bool val = validate(context);
    if (val) {
      try {
        apiResponse = await _repo.login(userName, password);

        debugPrint('************* Login successful, access token saved: ${apiResponse.data}');
        debugPrint('************* Login successful, access token saved: ${apiResponse.data != null}');

        if (apiResponse.data != null) {
          LoginData? loginData = apiResponse.data;

          if (loginData!.accessToken != null) {

            final jwt = loginData.accessToken!;

            // قم بفصل الأجزاء
            final parts = jwt.split('.');
            if (parts.length != 3) {
              debugPrint('Invalid JWT');

              return;
            }

            // فك التشفير للـ Header
            final header = utf8.decode(base64Url.decode(base64Url.normalize(parts[0])));
            debugPrint('-----Header: $header');


            // فك التشفير للـ Payload
            final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
            debugPrint('-----Payload: $payload');
            // تحويل الـ Payload إلى JSON
            final Map<String, dynamic> payloadMap = json.decode(payload);

            debugPrint('Name: $payloadMap');

            // التوقيع (Signature)
            final signature = parts[2];
            debugPrint('Signature: $signature');

            String role = payloadMap['role'];
            String userId = payloadMap['nameid'];
            String fullname = payloadMap['fullname'];


            debugPrint('userId: $userId');
            debugPrint('role: $role');
            debugPrint('fullname: $fullname');

            await UserPreferences().saveString(
              key: AppStrings.loginTokenKey,
              value: loginData.accessToken!,
            );
            await UserPreferences().saveString(
              key: AppStrings.refreshToken,
              value: loginData.refreshToken!,
            );
            await UserPreferences().saveString(
              key: AppStrings.userIdKey,
              value: userId,
            );
            await UserPreferences().saveString(
              key: AppStrings.userNameKey,
              value: fullname,
            );


            // debugPrint('Login successful, access token saved: ${loginData.accessToken}');

            commonViewModel.setLoginIn(true);
            commonViewModel.setCurrentUserId(userId);
            commonViewModel.setCurrentUserName(fullname);

            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MainWrapperScreen()),
            );
          }
        }
      } on DioException catch (e) {
        _isLoading = false;
        notifyListeners();

        if (e.response != null) {
          debugPrint('error in login e : $e');

          String errorMessage = e.response?.data['message'];

          // String message = errorMessage.contains('Invalid username or password')? S.of(context)!.login : 'An error occurred';

          debugPrint('error message1 $errorMessage');
          await showErrorDialog(
            context: context,
            message: S.of(context)!.errorHap,
            description: errorMessage,
          );
        } else {
          String errorMessage = 'Network error: ${e.message}';
          debugPrint('error in login $errorMessage');
        }
      } catch (e) {
        _isLoading = false;
        notifyListeners();

        debugPrint('***********error in login ${e.toString()}');

        // OverlayHelper.showErrorToast(context, S.of(context)!.anErrorOccurred);
      }
      _isLoading = false;
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  changeObscureText(bool obscureText1) {
    obscureText = obscureText1;
    notifyListeners();
  }

  Future callLoginApi(BuildContext context) async {}

  emailOnChanged(String value) {
    userName = value;
    if (userName.isNotEmpty) {
      errorEmail = null;
    }
    notifyListeners();
  }

  passwordOnChanged(String value) {
    password = value;
    if (password.isNotEmpty) {
      errorPass = null;
    }
    notifyListeners();
  }
}
