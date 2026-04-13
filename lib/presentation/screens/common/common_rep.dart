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

  // --- دوال إدارة المدن (Cities) ---
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

  Future<bool> createCity(String name) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.post(EndPointsStrings.getCitiesEndPoint, data: {'name': name});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<bool> updateCity(int id, String name) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.put('${EndPointsStrings.getCitiesEndPoint}/$id', data: {'name': name});
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) { return false; }
  }

  Future<bool> deleteCity(int id) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.delete('${EndPointsStrings.getCitiesEndPoint}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) { return false; }
  }

  // --- دوال إدارة المناطق (Regions) ---
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

  Future<bool> createRegion(int cityId, String name) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.post(EndPointsStrings.getRegionsEndPoint, data: {'cityId': cityId, 'name': name});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<bool> updateRegion(int regionId, int cityId, String name) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.put('${EndPointsStrings.getRegionsEndPoint}/$regionId', data: {'cityId': cityId, 'name': name});
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) { return false; }
  }

  Future<bool> deleteRegion(int regionId) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.delete('${EndPointsStrings.getRegionsEndPoint}/$regionId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) { return false; }
  }
}
