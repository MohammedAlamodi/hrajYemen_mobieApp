import 'package:flutter/material.dart';
import '../../../../model/product_model.dart';
import '../../../model/category_model.dart';
import '../home/home_repo.dart';

class CategoryProductsViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();
  List<ProductModel> _products = [];

  bool _isLoading = true;

  List<ProductModel> get products => _products;

  bool get isLoading => _isLoading;
  bool _isLoadingMore = false; // تحميل المزيد (Pagination)
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;

  bool get isLoadingMore => _isLoadingMore;

  // --- المتغيرات ---
  List<SubCategoryModel> _subCategories = [];
  bool _isLoadingSubCategories = false;

  // حفظ القسم الفرعي المختار (اختياري، لتمشيط الفلترة لاحقاً)
  int? _selectedSubCategoryId;

  // --- Getters ---
  List<SubCategoryModel> get subCategories => _subCategories;

  bool get isLoadingSubCategories => _isLoadingSubCategories;

  int? get selectedSubCategoryId => _selectedSubCategoryId;

  // --- دالة الجلب ---
  Future<void> getSubCategories(int categoryId) async {
    _isLoadingSubCategories = true;
    _subCategories = []; // تصفير القائمة القديمة
    notifyListeners();

    try {
      _subCategories = await _repo.fetchSubCategories(categoryId);
    } catch (e) {
      print("Error loading subcategories: $e");
    } finally {
      _isLoadingSubCategories = false;
      notifyListeners();
    }
  }

  // دالة لتغيير القسم الفرعي المختار
  void selectSubCategory({required int categoryId, required int subCategoryId}) {
    if (_selectedSubCategoryId == subCategoryId) {
      // _selectedSubCategoryId = null; // إلغاء التحديد إذا تم الضغط عليه مرة أخرى
    } else {
      _selectedSubCategoryId = subCategoryId;
      fetchProductsByCategory(categoryId, _selectedSubCategoryId ?? 0);
    }
    notifyListeners();
  }

  Future<void> initData(int categoryId) async {
    _selectedSubCategoryId = null;
    _products = [];
    _isLoading = true;
    notifyListeners();

    await getSubCategories(categoryId).then((_) async {
      if(_subCategories.isNotEmpty) {
        _selectedSubCategoryId = _subCategories.first.id;
        await fetchProductsByCategory(categoryId, _selectedSubCategoryId ?? 0);
      }
    });
    _isLoading = false;
    notifyListeners();
  }

  // جلب المنتجات حسب ID القسم
  Future<void> fetchProductsByCategory(int categoryId, int subCategoryId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentPage = 1;
      // هنا المفروض ترسل الـ categoryId للسيرفر
      // سنستخدم دالة الجلب العادية للمحاكاة
      _products = await _repo.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
        categoryId: categoryId,
        subCategoryId: subCategoryId
      );

      _hasMoreData = _products.length >= _pageSize;
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final newProducts = await _repo.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
      );

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
