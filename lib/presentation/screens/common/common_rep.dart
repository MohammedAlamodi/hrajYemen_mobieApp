import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ye_hraj/model/cities_model.dart';
import 'package:ye_hraj/model/region_model.dart';

import '../../../configurations/data/api_services.dart';
import '../../../configurations/data/end_points_manager.dart';

class CommonViewRepository {
  CommonViewRepository._internal();

  static final CommonViewRepository _singleton =
      CommonViewRepository._internal();

  factory CommonViewRepository() {
    return _singleton;
  }

  Future<List<CitiesModel>> fetchCities() async {
    await ApiService().getToken();

    try {
      // 1. الاتصال بالـ API (تأكد من تعديل الرابط ليتناسب مع مشروعك)
      final response = await ApiService().dio.get(EndPointsStrings.getCitiesEndPoint); // أو حسب مسار الـ API عندك

      // 2. معالجة البيانات (لأنها ترجع مصفوفة مباشرة List)
      if (response.statusCode == 200 && response.data != null) {

        // التحقق مما إذا كانت البيانات مصفوفة مباشرة (مثل الـ JSON الذي أرسلته)
        if (response.data is List) {
          List<CitiesModel> categories = (response.data as List)
              .map((e) => CitiesModel.fromJson(e))
              .toList();
          return categories;
        }
        // أو إذا كانت مغلفة بـ data (احتياطياً)
        else if (response.data is Map && response.data['data'] != null) {
          List<CitiesModel> categories = (response.data['data'] as List)
              .map((e) => CitiesModel.fromJson(e))
              .toList();
          return categories;
        }
      }

      return []; // إرجاع قائمة فارغة إذا لم تكن هناك بيانات

    } on DioException catch (e) {
      // ⚠️ معالجة أخطاء الشبكة
      debugPrint("خطأ في الاتصال بالشبكة (Categories): ${e.message}");
      return [];

    } catch (e) {
      // ⚠️ معالجة أخطاء التحويل (Parsing)
      debugPrint("خطأ في تحويل بيانات الأقسام: $e");
      return [];
    }
  }

  Future<List<RegionModel>> fetchRegion(int cityId) async {
    await ApiService().getToken();

    try {
      // 1. الاتصال بالـ API (تأكد من تعديل الرابط ليتناسب مع مشروعك)
      final response = await ApiService().dio.get('${EndPointsStrings.getRegionsByCityEndPoint}/$cityId'); // أو حسب مسار الـ API عندك

      // 2. معالجة البيانات (لأنها ترجع مصفوفة مباشرة List)
      if (response.statusCode == 200 && response.data != null) {

        // التحقق مما إذا كانت البيانات مصفوفة مباشرة (مثل الـ JSON الذي أرسلته)
        if (response.data is List) {
          List<RegionModel> categories = (response.data as List)
              .map((e) => RegionModel.fromJson(e))
              .toList();
          return categories;
        }
        // أو إذا كانت مغلفة بـ data (احتياطياً)
        else if (response.data is Map && response.data['data'] != null) {
          List<RegionModel> categories = (response.data['data'] as List)
              .map((e) => RegionModel.fromJson(e))
              .toList();
          return categories;
        }
      }

      return []; // إرجاع قائمة فارغة إذا لم تكن هناك بيانات

    } on DioException catch (e) {
      // ⚠️ معالجة أخطاء الشبكة
      debugPrint("خطأ في الاتصال بالشبكة (Categories): ${e.message}");
      return [];

    } catch (e) {
      // ⚠️ معالجة أخطاء التحويل (Parsing)
      debugPrint("خطأ في تحويل بيانات الأقسام: $e");
      return [];
    }
  }

  // Future<List<CitiesModel>> getCities() async {
  //   await ApiService().getToken();
  //
  //   try {
  //     // 1. الاتصال بالسيرفر
  //     final response = await ApiService().dio.get(EndPointsStrings.getCitiesEndPoint);
  //
  //     // 2. فك تشفير البيانات بناءً على طريقتكم
  //     var result = ApiService.decodeResp(response);
  //
  //     // 3. التحقق من وجود البيانات وتحويلها
  //     if (result['data'] != null) {
  //       List<CitiesModel> cities = (result['data'] as List)
  //           .map((e) => CitiesModel.fromJson(e))
  //           .toList();
  //       return cities;
  //     } else {
  //       // في حال كان الرد ناجحاً لكن المصفوفة فارغة أو لا يوجد مفتاح 'data'
  //       return [];
  //     }
  //
  //   } on DioException catch (e) {
  //     // ⚠️ معالجة أخطاء الشبكة والسيرفر (Dio Errors)
  //     if (e.type == DioExceptionType.connectionTimeout ||
  //         e.type == DioExceptionType.receiveTimeout) {
  //       print("خطأ: انتهى وقت الاتصال بالسيرفر.");
  //     } else if (e.type == DioExceptionType.badResponse) {
  //       print("خطأ من السيرفر: الكود ${e.response?.statusCode}");
  //     } else if (e.type == DioExceptionType.connectionError) {
  //       print("خطأ: لا يوجد اتصال بالإنترنت.");
  //     } else {
  //       print("خطأ غير معروف في الشبكة: ${e.message}");
  //     }
  //
  //     // يمكنك إرجاع مصفوفة فارغة، أو رمي خطأ ليلتقطه الـ ViewModel ويظهره للمستخدم
  //     return []; // أو throw Exception('فشل الاتصال بالخادم');
  //
  //   } catch (e) {
  //     // ⚠️ معالجة أخطاء الكود (مثل فشل تحويل JSON إلى CityModel)
  //     print("خطأ في معالجة البيانات (Parsing Error): $e");
  //     return [];
  //   }
  // }

  // Future<List<RegionModel>> fetchRegionsByCity(int cityId) async {
  //   await ApiService().getToken();
  //
  //   try {
  //     // 1. الاتصال بالسيرفر
  //     final response = await ApiService().dio.get('${EndPointsStrings.getRegionsByCityEndPoint}/$cityId');
  //
  //     // 2. فك تشفير البيانات بناءً على طريقتكم
  //     var result = ApiService.decodeResp(response);
  //
  //     // 3. التحقق من وجود البيانات وتحويلها
  //     if (result['data'] != null) {
  //       List<RegionModel> regions = (result['data'] as List)
  //           .map((e) => RegionModel.fromJson(e))
  //           .toList();
  //       return regions;
  //     } else {
  //       // في حال كان الرد ناجحاً لكن المصفوفة فارغة أو لا يوجد مفتاح 'data'
  //       return [];
  //     }
  //
  //   } on DioException catch (e) {
  //     // ⚠️ معالجة أخطاء الشبكة والسيرفر (Dio Errors)
  //     if (e.type == DioExceptionType.connectionTimeout ||
  //         e.type == DioExceptionType.receiveTimeout) {
  //       print("خطأ: انتهى وقت الاتصال بالسيرفر.");
  //     } else if (e.type == DioExceptionType.badResponse) {
  //       print("خطأ من السيرفر: الكود ${e.response?.statusCode}");
  //     } else if (e.type == DioExceptionType.connectionError) {
  //       print("خطأ: لا يوجد اتصال بالإنترنت.");
  //     } else {
  //       print("خطأ غير معروف في الشبكة: ${e.message}");
  //     }
  //
  //     // يمكنك إرجاع مصفوفة فارغة، أو رمي خطأ ليلتقطه الـ ViewModel ويظهره للمستخدم
  //     return []; // أو throw Exception('فشل الاتصال بالخادم');
  //
  //   } catch (e) {
  //     // ⚠️ معالجة أخطاء الكود (مثل فشل تحويل JSON إلى CityModel)
  //     print("خطأ في معالجة البيانات (Parsing Error): $e");
  //     return [];
  //   }
  // }
}
