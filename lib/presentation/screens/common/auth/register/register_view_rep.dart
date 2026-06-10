import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../../configurations/data/api_services.dart';
import '../../../../../configurations/data/end_points_manager.dart';
import 'package:dio/dio.dart';

import '../../../../custom_widgets/custom_text.dart';

class RegistrationViewRepository {
  RegistrationViewRepository._internal();

  static final RegistrationViewRepository _singleton =
      RegistrationViewRepository._internal();

  factory RegistrationViewRepository() {
    return _singleton;
  }

  Future<bool> registerUser({
    required BuildContext context,
    String? name,
    required String email,
    required String password,
    String? phoneNumber,
    String? bio,
    int? cityId,
    int? regionId,
    File? personalPhoto,
  }) async {
    try {
      // 1. تجهيز البيانات النصية (لاحظ تحويل الأرقام إلى نصوص)
      Map<String, dynamic> data = {
        "email": email,
        "password": password,
        if (name != null && name.isNotEmpty) "name": name,
        if (phoneNumber != null && phoneNumber.isNotEmpty) "phoneNumber": phoneNumber,
        if (bio != null && bio.isNotEmpty) "bio": bio,
        // 🔥 التحويل إلى نص هنا مهم جداً جداً لسيرفرات .NET
        if (cityId != null) "cityId": cityId.toString(),
        if (regionId != null) "regionId": regionId.toString(),
      };

      debugPrint("بيانات التسجيل: ${data.toString()}");

      FormData formData = FormData.fromMap(data);

      // 2. إضافة الصورة الشخصية إذا قام المستخدم باختيارها
      if (personalPhoto != null) {
        formData.files.add(
          MapEntry(
            "PersonalPhoto", // 👈 تأكد أن الحرف الأول Capital إذا كان السيرفر يطلبه هكذا
            await MultipartFile.fromFile(
              personalPhoto.path,
              filename: personalPhoto.path.split('/').last,
            ),
          ),
        );
      }

      // 3. إرسال الطلب للسيرفر
      final response = await ApiService().dio.post(
        EndPointsStrings.postRegisterClientEndPoint,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }else{
        if(response.statusCode == 400){
          debugPrint("خطأ في التسجيل: ${response.data}");
          if(response.data != null && response.data is Map<String, dynamic>){
            if(response.data.containsKey('message')){
              if(!context.mounted) return false;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: CustomText(
                    size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
                    title: response.data['message'],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              debugPrint("تفاصيل الأخطاء: ${response.data['message']}");
            }
          }
        }
      }
      return false;

    } on DioException catch (e) {
      debugPrint("خطأ في التسجيل: ${e.message}");
      if (e.response != null) {
        debugPrint("تفاصيل السيرفر: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
      return false;
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    required String email,
    required String password,
    String? phoneNumber,
    String? bio,
    int? cityId,
    int? regionId,
    File? personalPhoto,
  }) async {
    try {
      // 1. تجهيز البيانات النصية
      Map<String, dynamic> data = {
        'id': userId,
        'email': email,
        'password': password,
        if (name != null && name.isNotEmpty) 'name': name,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
        if (cityId != null) 'cityId': cityId,
        if (regionId != null) 'regionId': regionId,
      };

      FormData formData = FormData.fromMap(data);

      // 2. إضافة الصورة الشخصية إذا قام المستخدم باختيارها
      if (personalPhoto != null) {
        formData.files.add(
          MapEntry(
            'personalPhoto', // 👈 نفس الاسم المطلوب في الـ API
            await MultipartFile.fromFile(
              personalPhoto.path,
              filename: personalPhoto.path.split('/').last,
            ),
          ),
        );
      }

      await ApiService().getToken();

      // 3. إرسال الطلب للسيرفر
      final response = await ApiService().dio.put(
        "${EndPointsStrings.putClientEndPoint}/$userId", // 👈 تأكد من مسار الـ API الصحيح للتسجيل
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;

    } on DioException catch (e) {
      debugPrint("خطأ في التسجيل: ${e.message}");
      if (e.response != null) {
        debugPrint("تفاصيل السيرفر: ${e.response?.data}");
        // يمكنك رمي استثناء (throw Exception) هنا لعرض رسالة السيرفر في الواجهة
      }
      return false;
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
      return false;
    }
  }

  Future<bool> resetPassword({required String phone, required String newPassword}) async {
    try {
      final response = await ApiService().dio.post(
        EndPointsStrings.resetPasswordEndPoint,
        data: {
          "userId": phone,
          "password": newPassword,
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;

    } on DioException catch (e) {
      debugPrint("خطأ في إعادة تعيين كلمة المرور: ${e.message}");
      if (e.response != null) {
        debugPrint("تفاصيل السيرفر: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
      return false;
    }
  }
}

extension on Map<String, dynamic> {
  String toJosnString() {
    return this.entries.map((e) => '"${e.key}": "${e.value}"').join(', ');
  }
}
