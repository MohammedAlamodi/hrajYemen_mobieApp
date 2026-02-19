import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/pay_commission_item_model.dart';

class DynamicItemsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _cacheKey = 'cached_dynamic_items';

  // دالة تجلب البيانات (تحاول تجيب الجديد، لو فشلت تجيب القديم)
  Future<List<DynamicItemModel>> getItems() async {
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
}