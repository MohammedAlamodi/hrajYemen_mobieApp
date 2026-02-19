import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../configurations/data/api_services.dart';
import '../../../../../configurations/data/end_points_manager.dart';
import 'package:flutter/foundation.dart';

import '../../../../../configurations/resources/strings_manager.dart';
import '../../../../../configurations/user_preferences.dart';
import '../../../../../model/login_model.dart';

class LoginViewRepository {
  LoginViewRepository._internal();

  static final LoginViewRepository _singleton = LoginViewRepository._internal();

  factory LoginViewRepository() {
    return _singleton;
  }

  Future<LoginResponseModel?> loginApp(
       {
         required BuildContext context,
        required String username,
        required String password,
      }) async {
    LoginResponseModel? apiResponse = LoginResponseModel();

    debugPrint("error in user name $apiResponse ");

    await ApiService().getBaseUrlAndToken();
    return ApiService().dio.post(EndPointsStrings.loginAppEndPoint, data: {
      'username': username,
      'password': password,
    }).then((value) async {
      debugPrint("value loginAppSuccess $value");

      var results = ApiService.decodeResp(value);

      apiResponse = LoginResponseModel.fromJson(results);
      debugPrint(apiResponse.toString());

      return apiResponse;
    });
  }

}
