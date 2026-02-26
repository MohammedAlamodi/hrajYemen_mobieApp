import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';

import '../../presentation/custom_widgets/custom_text.dart';
import '../localization/i18n.dart';
import '../resources/strings_manager.dart';
import '../user_preferences.dart';
import 'package:ye_hraj/main.dart';

class ApiService {
  static final ApiService _singleton = ApiService._internal();
  factory ApiService() => _singleton;
  ApiService._internal();

  static dynamic decodeResp(d) {
    const JsonDecoder decoder = JsonDecoder();
    if (d is Response) {
      final dynamic jsonBody = d.data;
      final statusCode = d.statusCode;

      if (statusCode == null || statusCode < 200 || statusCode >= 300 || jsonBody == null) {
        throw Exception("statusCode: $statusCode");
      }

      if (jsonBody is String && jsonBody.isNotEmpty) {
        return decoder.convert(jsonBody);
      } else {
        debugPrint('jsonBody $jsonBody, type: ${jsonBody.runtimeType}');
        return jsonBody;
      }
    } else {
      throw d;
    }
  }

  String? token;

  Future<void> getToken() async {
    token = await UserPreferences().getString(key: AppStrings.loginTokenKey, defaultValue: '');

    debugPrint('token is ${token ?? "access_token_100344fa3edf541776e61f80aa2231ded1d34eb2"}');
  }

  bool _shouldForceLogoutFromResponse(Response resp) {
    // 1. استثناء روابط تسجيل الدخول من الطرد الإجباري
    final path = resp.requestOptions.path;
    if (path.contains('login') || path.contains('authenticate')) {
      return false; // لا تطرد المستخدم إذا فشل وهو يحاول الدخول أصلاً
    }

    final code = resp.statusCode ?? 0;
    final body = resp.data?.toString() ?? '';

    // اعتبر أي 401/403 أو نص يدل على انتهاء الجلسة كخروج إجباري
    if (code == 401 || code == 403) return true;
    if (body.contains('invalid access token') || body.contains('Access Denied')|| body.contains('The token expired')) return true;

    return false;
  }

  // استخرج فقط جزء الكوكي "name=value"
  String _extractCookiePair(String setCookieHeader) {
    // مثال: "session_id=abc123; Expires=...; Path=/"
    final firstPart = setCookieHeader.split(';').first.trim();
    return firstPart; // "session_id=abc123"
  }

  Dio get dio {
    final dio = Dio();

    dio.options
      ..baseUrl = EndPointsStrings.baseUrl
      ..headers = {
        "content-type": "application/json",
        "accept": "application/json",
        // لو السيرفر يحتاج هذا الهيدر باسم "rrr" خليه، وإلا استبدله بـ Authorization أو المطلوب
        // "rrr": "$token",
        'Authorization': 'Bearer $token',
      }
    // مهم: فعّل validateStatus دائمًا إذا حاب تتعامل مع الأخطاء داخل onResponse
      ..validateStatus = (_) => true;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            debugPrint("Request From uri:${options.uri},");
            debugPrint("Request From queryParameters:${options.queryParameters}");
            debugPrint("Request From data:${options.data},");
          }

          // أضف الكوكي الصحيح
          final rawCookie = await UserPreferences()
              .getString(key: AppStrings.cookie, defaultValue: '');
          if (rawCookie.isNotEmpty) {
            // إن كان مخزنًا كـ Set-Cookie كامل، استخرج الجزء الصحيح
            final cookiePair = rawCookie.contains(';') ? _extractCookiePair(rawCookie) : rawCookie;
            options.headers['cookie'] = cookiePair; // مثال: "session_id=abc123"
          }

          debugPrint('header cookie ${options.headers['cookie']}');

          handler.next(options);
        },
        onResponse: (response, handler) async {
          if (kDebugMode) {
            debugPrint("Response From:${response.requestOptions.method} "
                "${response.requestOptions.baseUrl} ${response.requestOptions.path}"
                "----->${response.statusCode}");
            debugPrint("Response From:${response.data},");
          }

          // عند تسجيل الدخول، خزّن الكوكي بشكل صحيح
          if (response.requestOptions.uri.toString().contains("login")) {
            final setCookieHeaders = response.headers['set-cookie'] ?? [];
            if (setCookieHeaders.isNotEmpty) {
              // خزّن فقط "name=value" لتستخدمه في "Cookie:"
              final cookiePair = _extractCookiePair(setCookieHeaders.first);
              await UserPreferences()
                  .saveString(key: AppStrings.cookie, value: cookiePair);
            }
          }

          // لو انتهت الجلسة
          if (_shouldForceLogoutFromResponse(response)) {
            // لا نعمل await حتى لا نعلّق سلسلة الـ interceptor
            Overlay.showLogoutDialog();
          }

          handler.next(response);
        },
        onError: (e, handler) async {
          if (kDebugMode) {
            debugPrint("dio error --------- ${e.response}");
            debugPrint("dio error --------- ${e.error}");
          }

          // في الـRelease، الأخطاء 401/403 تجي هنا
          final resp = e.response;
          if (resp != null && _shouldForceLogoutFromResponse(resp)) {
            Overlay.showLogoutDialog();
          }

          // بإمكانك إضافة معالجة رسائل السيرفر المعيارية هنا
          handler.next(e);
        },
      ),
    );

    return dio;
  }
}

class Overlay {
  static Future<void> showLogoutDialog() async {
    final context = MyApp.navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Navigator context is null');
      return;
    }

    if (!context.mounted) {
      // احتياط لو تم التخلص من السياق
      debugPrint('Context not mounted');
      return;
    }

    // منع تكرار الديالوج إذا كان مفتوح
    // يمكنك إضافة منطق حالة عامة لو تكرّر النداء
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(title: S.of(context)!.error),
          content: CustomText(
            title: S.of(context)!.yourAccessDenied,
            size: Theme.of(context).textTheme.bodySmall!.fontSize,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                UserPreferences().logout(context);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const CustomText(title: 'OK'),
            ),
          ],
        );
      },
    );
  }
}
