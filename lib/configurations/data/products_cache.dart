import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/product_model.dart';

/// طبقة تخزين مؤقت (Cache) لخلاصة المنتجات في الصفحة الرئيسية (بدون فلاتر).
/// الهدف: عرض آخر منتجات معروفة فوراً عند فتح التطبيق ثم تحديثها من السيرفر.
class ProductsCache {
  static const String _homeFeedKey = 'cached_home_products';

  /// حفظ قائمة المنتجات في الكاش (يُستخدم بعد كل جلب ناجح من السيرفر للخلاصة).
  Future<void> saveProducts(List<ProductModel> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toCacheJson()).toList();
      await prefs.setString(_homeFeedKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('خطأ في حفظ كاش المنتجات: $e');
    }
  }

  /// قراءة المنتجات المخزّنة. تُعيد قائمة فارغة إن لم يوجد كاش.
  Future<List<ProductModel>> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_homeFeedKey);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('خطأ في قراءة كاش المنتجات: $e');
      return [];
    }
  }

  /// مسح الكاش (اختياري، مثلاً عند تسجيل الخروج).
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_homeFeedKey);
    } catch (e) {
      debugPrint('خطأ في مسح كاش المنتجات: $e');
    }
  }
}
