import 'package:dio/dio.dart';
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

  Future<LoginResponseModel> login(String email, String password) async {
    try {
      final response = await ApiService().dio.post(
        EndPointsStrings.loginUserEndPoint, // استبدله بـ EndPointsStrings.loginEndPoint
        data: {
          "email": email,       // أو "username" حسب ما يقبله الباك إند
          "password": password,
        },
      );

      var result = ApiService.decodeResp(response);

      // apiResponse = LoginResponseModel.fromJson(results);

      // التحقق من نجاح العملية حسب الـ JSON الخاص بك (success: true)
      if (result['success'] == true && result['data'] != null) {
        return LoginResponseModel.fromJson(result);
      } else {
        // إذا كان success: false، نرمي رسالة الخطأ القادمة من السيرفر
        throw Exception(result['message'] ?? 'فشل تسجيل الدخول. يرجى المحاولة لاحقاً.');
      }

    } on DioException catch (e) {
      // ⚠️ معالجة أخطاء الشبكة والسيرفر
      if (e.response != null) {
        // السيرفر رد بخطأ (مثلاً 401 غير مصرح، أو 400 بيانات خاطئة)
        final errorData = e.response?.data;

        // محاولة استخراج رسالة الخطأ من السيرفر (مثل "كلمة المرور خاطئة")
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('خطأ في بيانات الدخول، يرجى التأكد من الإيميل وكلمة المرور.');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهى وقت الاتصال. السيرفر لا يستجيب.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('لا يوجد اتصال بالإنترنت.');
      } else {
        throw Exception('حدث خطأ غير متوقع في الشبكة.');
      }
    } catch (e) {
      // ⚠️ أي أخطاء أخرى (مثل مشكلة في تحويل الـ JSON)
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Future<LoginResponseModel?> loginApp(
  //      {
  //        required BuildContext context,
  //       required String username,
  //       required String password,
  //     }) async {
  //   LoginResponseModel? apiResponse = LoginResponseModel();
  //
  //   debugPrint("error in user name $apiResponse ");
  //
  //   await ApiService().getBaseUrlAndToken();
  //   return ApiService().dio.post(EndPointsStrings.loginUserEndPoint, data: {
  //     'username': username,
  //     'password': password,
  //   }).then((value) async {
  //     debugPrint("value loginAppSuccess $value");
  //
  //     var results = ApiService.decodeResp(value);
  //
  //     apiResponse = LoginResponseModel.fromJson(results);
  //     debugPrint(apiResponse.toString());
  //
  //     return apiResponse;
  //   });
  // }
}
