// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../resources/strings_manager.dart';
import '../user_preferences.dart';
import 'end_points_manager.dart';

class ApiService {
  // String token;
  static final ApiService _singleton = ApiService._internal();

  factory ApiService() {
    return _singleton;
  }

  ApiService._internal();

  static dynamic decodeResp(d) {
    const JsonDecoder decoder = JsonDecoder();
    if (d is Response) {
      final dynamic jsonBody = d.data;
      final statusCode = d.statusCode;

      if (statusCode! < 200 || statusCode >= 300 || jsonBody == null) {
        throw Exception("statusCode: $statusCode");
      }

      if (jsonBody is String && jsonBody.isNotEmpty) {
        return decoder.convert(jsonBody);
      } else {
        return jsonBody;
      }
    } else {
      throw d;
    }
  }

  String? token;

  // String token2 = "access_token_29f5de49d5f3f219115eb283ea81c411a3a05746";

  getBaseUrlAndToken() async {
    // UserPreferences userPreferences = UserPreferences();

    token = await UserPreferences().getString(
        key: AppStrings.loginTokenKey, defaultValue: '');

    debugPrint('token is ${token ?? "null"}');
  }

  Dio get dio {
    Dio dio = Dio();
    dio.options.baseUrl = EndPointsStrings.baseUrl ?? '';
    dio.options.headers = {
      "content-type": "application/json",
      "accept": "application/json",
      // "rrr": "$token",
    };

    dio.interceptors.add(
        InterceptorsWrapper(onRequest: (RequestOptions options, handler) async {
      if (kDebugMode) {
        debugPrint("Request From uri:${options.uri},");
        debugPrint("Request From queryParameters:${options.queryParameters}");
        debugPrint("Request From data:${options.data},");
      }

      // Add cookies to the request
      // options.headers['cookie'] = userPreferences.prefs.getString(AppStrings.cookie);
      // debugPrint("34578093458g35%GF@#");
      debugPrint('header cookie ${options.headers['cookie']}');
      return handler.next(options); //continue
    }, onResponse: (Response response, handler) async {
      if (kDebugMode) {
        debugPrint("Response From:${response.requestOptions.method}"
            "${response.requestOptions.baseUrl}${response.requestOptions.path}"
            "----->${response.statusCode}");
        debugPrint("Response From:${response.data},");
      }

      if (response.requestOptions.uri.toString().contains("login")) {
        // Store cookies from the response
        final setCookieHeaders = response.headers['set-cookie'] ?? [];
        for (var i in setCookieHeaders) {
          debugPrint("34578093450g35%GF@# ${setCookieHeaders.length}");
          // debugPrint(i);
        }
        // userPreferences.prefs
        //     .setString(AppStrings.cookie, setCookieHeaders.first);
      }

      return handler.next(response); // continue
    }, onError: (DioException e, handler) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 400) {
          final message = e.response?.data['message'] ?? 'Unknown error';
          debugPrint("Error message: $message");

          // هذا الكود علشان يظهر الرساله المؤرسله من السرفر
          DioException exception = e.copyWith(message: message);
          return handler.next(exception);
        }

        if (e.response != null &&
            e.response!.toString().contains(
                "Either the server is overloaded or there is an error")) {
          debugPrint("onError Either the server is ##%@%@");
          // userPreferences.clearLogout(context);
        }
        if (kDebugMode) {
          print("9f8a6d87%675d6s7");
          print(e.requestOptions.headers);
          debugPrint("dio error ---------${e.response}");
          debugPrint("dio error ---------${e.error}");
        }
      }
      return handler.next(e); //continue
    }));
    return dio;
  }
}
