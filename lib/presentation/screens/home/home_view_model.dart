import 'package:flutter/material.dart';
import '../../../model/category_model.dart';
import '../../../model/product_model.dart';
import 'home_repo.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];

  bool _isLoading = false;      // تحميل أولي
  bool _isLoadingMore = false;  // تحميل المزيد (Pagination)
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;     // هل يوجد بيانات متبقية؟

  // Getters
  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;


  Future<void> getInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPage = 1;

      // جلب المنتجات والفئات بالتوازي (لتحسين السرعة)
      final results = await Future.wait([
        _repo.fetchProducts(page: _currentPage, limit: _pageSize),
        _repo.fetchCategories(),
      ]);

      _products = results[0] as List<ProductModel>;
      _categories = results[1] as List<CategoryModel>;

      _hasMoreData = _products.length >= _pageSize;
    } catch (e) {
      debugPrint("خطأ في معالجة المنتجات: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPage = 1;
      _products = await _repo.fetchProducts(page: _currentPage, limit: _pageSize);
      _hasMoreData = _products.length >= _pageSize;
    } catch (e) {
      debugPrint("خطأ في تحديث المنتجات: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// دالة جلب المزيد (تستدعى عند الوصول لنهاية القائمة)
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final newProducts = await _repo.fetchProducts(page: _currentPage, limit: _pageSize);

      if (newProducts.isEmpty) {
        _hasMoreData = false;
      } else {
        _products.addAll(newProducts);
      }
    } catch (e) {
      print("Error loading more: $e");
      _currentPage--; // تراجع عن زيادة الصفحة في حال الخطأ
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}