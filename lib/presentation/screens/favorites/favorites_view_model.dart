// view_models/favorites_view_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/product_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  List<ProductModel> _favorites = [];

  List<ProductModel> get favorites => _favorites;

  FavoritesViewModel() {
    loadFavorites(); // استرجاع البيانات عند فتح التطبيق
  }

  // 1. منطق التبديل (إضافة/حذف)
  void toggleFavorite(ProductModel product) {
    final isExist = _favorites.any((element) => element.id == product.id);

    if (isExist) {
      _favorites.removeWhere((element) => element.id == product.id);
    } else {
      _favorites.add(product);
    }

    _saveToLocal(); // حفظ التغييرات فوراً
    notifyListeners();
  }

  // 2. التحقق هل المنتج مفضل؟
  bool isFavorite(int productId) {
    return _favorites.any((element) => element.id == productId);
  }

  // --- دوال التخزين المحلي (Private) ---

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    // تحويل القائمة إلى JSON String
    final String encodedData = json.encode(
      _favorites.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('user_favorites', encodedData);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString('user_favorites');

    if (favoritesString != null) {
      final List<dynamic> decodedData = json.decode(favoritesString);
      _favorites = decodedData.map((e) => ProductModel.fromJson(e)).toList();
      notifyListeners();
    }
  }
}