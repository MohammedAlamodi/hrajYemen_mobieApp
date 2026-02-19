import 'package:flutter/material.dart';
import '../../../../model/product_model.dart';
import '../home/home_repo.dart';

class CategoryProductsViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  // جلب المنتجات حسب ID القسم
  Future<void> fetchProductsByCategory(int categoryId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // هنا المفروض ترسل الـ categoryId للسيرفر
      // سنستخدم دالة الجلب العادية للمحاكاة
      _products = await _repo.fetchProducts(page: 1);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}