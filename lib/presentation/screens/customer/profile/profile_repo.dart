import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';
import 'package:ye_hraj/configurations/resources/strings_manager.dart';
import '../../../../configurations/data/api_services.dart';
import '../../../../configurations/user_preferences.dart';
import '../../../../model/pay_commission_item_model.dart';
import '../../../../model/user_profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _cacheKey = 'cached_dynamic_items';

  // دالة تجلب البيانات (تحاول تجيب الجديد، لو فشلت تجيب القديم)
  Future<List<DynamicItemModel>> getCommissionPayItems() async {
    try {
      // 1. محاولة الجلب من الفايربيس
      final snapshot = await _firestore.collection('promoted_items').get();

      List<DynamicItemModel> items = snapshot.docs.map((doc) {
        return DynamicItemModel.fromMap(doc.data(), doc.id);
      }).toList();

      // 2. إذا نجح الجلب، احفظها لوكل (تحديث الكاش)
      _saveToLocal(items);

      return items;
    } catch (e) {
      // 3. إذا فشل (مافي نت)، جيب من الكاش
      print("Error fetching from Firebase, loading local: $e");
      return _loadFromLocal();
    }
  }

  // حفظ في الشيرد بريفرنس
  Future<void> _saveToLocal(List<DynamicItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_cacheKey, encodedData);
  }

  // استرجاع من الشيرد بريفرنس
  Future<List<DynamicItemModel>> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_cacheKey);
    if (data != null) {
      final List decoded = json.decode(data);
      return decoded.map((e) => DynamicItemModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<UserProfileModel?> fetchUserProfile() async {
    try {
      String userId = await UserPreferences().getString(key: AppStrings.userIdKey, defaultValue: '');
      // 👈 تأكد من تعديل هذا المسار ليتطابق مع الـ API الخاص بك (مثلاً: api/Account/Profile)
      final response = await ApiService().dio.get('${EndPointsStrings.getUserProfileEndPoint}/$userId');

      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;

        // إذا كان السيرفر يرجع الكائن مباشرة
        if (data is Map<String, dynamic>) {
          // إذا كان مغلفاً بـ data
          if (data.containsKey('data') && data['data'] != null) {
            return UserProfileModel.fromJson(data['data']);
          }
          return UserProfileModel.fromJson(data);
        }
      }
      return null;

    } on DioException catch (e) {
      debugPrint("خطأ شبكة في جلب بيانات المستخدم: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("خطأ في معالجة بيانات المستخدم: $e");
      return null;
    }
  }
}