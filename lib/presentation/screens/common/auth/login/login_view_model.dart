import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../../../configurations/resources/strings_manager.dart';
import '../../../../../configurations/user_preferences.dart';
import '../../../../../model/login_model.dart';
import '../../../../custom_widgets/dialog/error_dialog.dart';
import '../../../../custom_widgets/dialog/overlay_helper.dart';
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

  // UserClass? userClass;
  // User? user;
  String? errorEmail;
  String? errorPass;
  bool rememberMyLogin = false;

  // password hidden
  bool obscureText = true;

  // GlobalKey<ScaffoldState> loginFormKey = GlobalKey<ScaffoldState>();

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

  onLoginClick(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    LoginResponseModel? apiResponse;


    bool val = validate(context);
    if (val) {
      try {
        apiResponse = await _repo
            .loginApp(context: context,
            username: userName, password: password);

        if(apiResponse != null){
          LoginData? loginData = apiResponse.data;

          if(loginData!.accessToken != null){
            // UserPreferences userPreferences = UserPreferences();

            final jwt = loginData!.accessToken!;

            // قم بفصل الأجزاء
            final parts = jwt.split('.');
            if (parts.length != 3) {
              debugPrint('Invalid JWT');

              return Error();
            }

            // فك التشفير للـ Header
            final header = utf8.decode(base64Url.decode(base64Url.normalize(parts[0])));
            debugPrint('Header: $header');


            // فك التشفير للـ Payload
            final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
            debugPrint('Payload: $payload');
            // تحويل الـ Payload إلى JSON
            final Map<String, dynamic> payloadMap = json.decode(payload);

            debugPrint('Name: ${payloadMap['Name']}');
            debugPrint('CustomerId: ${payloadMap['CustomerId']}');
            debugPrint('SellerId: ${payloadMap['SellerId']}');
            debugPrint('email: ${payloadMap['email']}');
            debugPrint('sub: ${payloadMap['sub']}');

            // التوقيع (Signature)
            final signature = parts[2];
            debugPrint('Signature: $signature');

            // userPreferences.saveString(
            //     key: AppStrings.loginTokenKey,
            //     value: apiResponse.token ?? "null"
            // );
            //
            // if(payloadMap['CustomerId'] != null){
            //   userPreferences.saveString(
            //       key: AppStrings.userIdKey,
            //       value: payloadMap['CustomerId'] ?? "null");
            // }
            //
            // // if(payloadMap['SellerId'] != null){
            // //   userPreferences.saveString(
            // //       key: AppStrings.userIdKey,
            // //       value: payloadMap['SellerId'] ?? "null"
            // //   );
            // // }
            //
            // if(payloadMap['BankId'] != null){
            //   userPreferences.saveString(
            //       key: AppStrings.userIdKey,
            //       value: payloadMap['BankId'] ?? "null"
            //   );
            // }
            //
            // userPreferences.saveString(
            //     key: AppStrings.userNameKey,
            //     value: payloadMap['Name'] ?? "-");
            //
            // userPreferences.saveString(
            //     key: AppStrings.userEmailKey,
            //     value: payloadMap['email'] ?? "-");
            //
            // userPreferences.saveString(
            //     key: AppStrings.userTypeKey,
            //     value: apiResponse!.roles?[0] ?? "null");
          }
        }
        // if(apiResponse?.roles != null){
        //   if(apiResponse!.roles!.isNotEmpty){
        //     userName = '';
        //     password = '';
        //     if(apiResponse!.roles![0] == "Customer"){
        //       Navigator.pushNamedAndRemoveUntil(context,
        //         SwitchHomeScreen.routeName,
        //             (Route<dynamic> route) => false,
        //       );
        //     }else if(apiResponse!.roles![0] == "Bank"){
        //       Navigator.pushNamedAndRemoveUntil(context,
        //         BankHomeSwitchView.routeName,
        //             (Route<dynamic> route) => false,
        //       );
        //     }else{
        //
        //     }
        //   }
        // }

      } on DioException catch (e) {
        _isLoading = false;
        notifyListeners();

        if (e.response != null) {
          debugPrint('error in login e : $e');

          String errorMessage = e.response?.data['message'];

          // String message = errorMessage.contains('Invalid username or password')? S.of(context)!.login : 'An error occurred';

          debugPrint('error message1 $errorMessage');
          await showErrorDialog(context: context, message: S.of(context)!.errorHap
              , description: errorMessage);
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
