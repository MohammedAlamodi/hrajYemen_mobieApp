import 'package:flutter/material.dart';
import '../../../../../configurations/data/api_services.dart';
import '../../../../../configurations/data/end_points_manager.dart';
import 'singup_view_model.dart';
import 'package:dio/dio.dart';

class RegistrationViewRepository {
  RegistrationViewRepository._internal();

  static final RegistrationViewRepository _singleton =
      RegistrationViewRepository._internal();

  factory RegistrationViewRepository() {
    return _singleton;
  }

  Future<Map<String, dynamic>> registerUser(BuildContext context,
      {required RegisterModel model}) async {
    Map<String, dynamic>? apiResponse = {};

    FormData formData = FormData.fromMap({
      'Username': model.username,
      'Email': model.email,
      'Password': model.password,
      'Role': model.role?.name,
      'Name': model.name,
      'ForeignName': model.foreignName,
      'ContactInfo': model.contactInfo,
      'Address': model.address,
      'Logo': model.logo,
      'Phone': model.phone,
    });
    await ApiService().getToken();
    return ApiService().dio.post(EndPointsStrings.loginUserEndPoint,
        data: formData
    ).then((value) async {
      debugPrint("value loginAppSuccess $value");

      var results = ApiService.decodeResp(value);

      apiResponse = await results;
      debugPrint(apiResponse.toString());

      return results;
    });
  }
}
