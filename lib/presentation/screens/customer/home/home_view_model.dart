import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ye_hraj/presentation/screens/common/common_rep.dart';
import '../../../../model/category_model.dart';
import '../../../../model/cities_model.dart';
import '../../../../model/product_model.dart';
import 'home_repo.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();
  final CommonViewRepository _commRepo = CommonViewRepository();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];

  TextEditingController sherTextCont = TextEditingController(); // تحميل أولي

  bool _isLoading = false; // تحميل أولي
  bool _isProductLoading = false; // تحميل أولي
  bool _isLoadingMore = false; // تحميل المزيد (Pagination)
  int _currentPage = 1;
  final int _pageSize = 8;
  bool _hasMoreData = true; // هل يوجد بيانات متبقية؟

  // Getters
  List<ProductModel> get products => _products;

  List<CategoryModel> get categories => _categories;

  bool get isLoading => _isLoading;

  bool get isProductLoading => _isProductLoading;

  bool get isLoadingMore => _isLoadingMore;

  // --- متغيرات الفلترة والأقسام الفرعية ---
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  bool _isLoadingSubCategories = false;
  List<SubCategoryModel> _subCategories = [];

  int? get selectedCategoryId => _selectedCategoryId;

  int? get selectedSubCategoryId => _selectedSubCategoryId;

  bool get isLoadingSubCategories => _isLoadingSubCategories;

  List<SubCategoryModel> get subCategories => _subCategories;

  // --- دالة الضغط على القسم الرئيسي ---
  Future<void> toggleCategory(int categoryId) async {
    _currentPage = 1;

    if (_selectedCategoryId == categoryId) {
      // 1. إذا ضغط على نفس القسم المختار: نلغي الاختيار ونرجع كل المنتجات
      _selectedCategoryId = null;
      _selectedSubCategoryId = null;
      _subCategories.clear();

      _isProductLoading = true;
      notifyListeners();

      _products = await _repo.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubCategoryId,
        search: sherTextCont.text,
      );
      _hasMoreData = _products.length >= _pageSize;
    } else {
      // 2. إذا اختار قسماً جديداً: نحدد القسم ونظهر اللودنق للأقسام الفرعية
      _selectedCategoryId = categoryId;
      _selectedSubCategoryId = null; // تصفير القسم الفرعي
      _isLoadingSubCategories = true;
      _isProductLoading = true;

      notifyListeners();

      try {
        // جلب الأقسام الفرعية من السيرفر (استبدل هذه بالدالة الحقيقية في الـ Repo)
        _subCategories = await _repo.fetchSubCategories(categoryId);

        _isProductLoading = true;

        // جلب المنتجات المفلترة بالقسم الرئيسي
        _products = await _repo.fetchProducts(
          page: _currentPage,
          limit: _pageSize,
          categoryId: _selectedCategoryId,
          subCategoryId: _selectedSubCategoryId,
          search: sherTextCont.text,
        );
        _hasMoreData = _products.length >= _pageSize;
        notifyListeners();
      } catch (e) {
        print("خطأ في جلب الأقسام الفرعية: $e");
      } finally {
        _isLoadingSubCategories = false;
        _isProductLoading = false;
        notifyListeners();
      }
    }
    _isProductLoading = false;
    _isLoadingSubCategories = false;
    notifyListeners();
  }

  Future<void> onSearchTextChanged({BuildContext? context}) async {
    _currentPage = 1;
    _isProductLoading = true; // نفعّل اللودنق الخاص بالمنتجات
    _hasMoreData = true;      // نصفر حالة Pagination
    notifyListeners();

    if(context != null) {
      Navigator.of(context).pop();
    }
    try {
      final results = await _repo.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubCategoryId,
        search: sherTextCont.text,
        cityId: selectedCity?.id,
        minPrice: minPriceController.text.isNotEmpty
            ? double.tryParse(minPriceController.text)
            : null,
        maxPrice: maxPriceController.text.isNotEmpty
            ? double.tryParse(maxPriceController.text)
            : null,
      );

      _products = results; // تحديث القائمة بالنتائج الجديدة
      _hasMoreData = _products.length >= _pageSize;
    } catch (e) {
      debugPrint("خطأ في البحث: $e");
      _products = []; // في حال الخطأ نصفر القائمة لكي لا يظل اللودنق يعمل
    } finally {
      _isProductLoading = false; // ✅ نضمن إيقاف اللودنق مهما حدث
      _isLoading = false;        // ✅ احتياطاً نوقف اللودنق الكلي أيضاً
      notifyListeners();
    }
  }

  // --- دالة الضغط على القسم الفرعي ---
  Future<void> toggleSubCategory(int subCatId) async {
    _currentPage = 1;
    if (_selectedSubCategoryId == subCatId) {
      // إلغاء تحديد القسم الفرعي والعودة لمنتجات القسم الرئيسي
      _selectedSubCategoryId = null;

      _products = await _repo.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubCategoryId,
        search: sherTextCont.text,
      );

      _hasMoreData = _products.length >= _pageSize;
    } else {
      // تحديد القسم الفرعي وجلب منتجاته
      _selectedSubCategoryId = subCatId;

      _products = await _repo.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubCategoryId,
        search: sherTextCont.text,
      );
      _hasMoreData = _products.length >= _pageSize;
    }
    notifyListeners();
  }

  Future<void> getInitialData() async {
    if (_categories.isEmpty) {
      _isLoading = true;
    } else {
      _isProductLoading = true;
    }
    notifyListeners();

    try {
      _currentPage = 1;
      // جلب المنتجات والفئات بالتوازي (لتحسين السرعة)
      final results = await Future.wait([
        _repo.fetchProducts(
          page: _currentPage,
          limit: _pageSize,
          categoryId: _selectedCategoryId,
          subCategoryId: _selectedSubCategoryId,
          search: sherTextCont.text,
        ),
        _repo.fetchCategories(),
      ]);

      _products = results[0] as List<ProductModel>;
      _categories = results[1] as List<CategoryModel>;

      _hasMoreData = _products.length >= _pageSize;
    } catch (e) {
      debugPrint("خطأ في معالجة المنتجات: $e");
    } finally {
      _isLoading = false;
      _isProductLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    _isProductLoading = true;
    notifyListeners();

    try {
      _currentPage = 1;
      _products = await _repo.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubCategoryId,
        search: sherTextCont.text,
      );
      _hasMoreData = _products.length >= _pageSize;
    } catch (e) {
      debugPrint("خطأ في تحديث المنتجات: $e");
    } finally {
      _isProductLoading = false;
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
      final newProducts = await _repo.fetchProducts(
        page: _currentPage,
        limit: _pageSize,
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubCategoryId,
        search: sherTextCont.text,
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

  // حالة المدن
  List<CitiesModel> cities = [];
  bool isLoadingCities = false;
  String? errorMessage;

  // حالة الفلاتر المختارة
  CitiesModel? selectedCity;
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  HomeViewModel() {
    fetchCities();
  }

  Future<void> fetchCities() async {
    isLoadingCities = true;
    errorMessage = null;
    notifyListeners();

    try {
      cities = await _commRepo.fetchCities();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingCities = false;
      notifyListeners();
    }
  }

  void selectCity(CitiesModel city) {
    // إذا ضغط على نفس المدينة يمسح الاختيار، وإلا يختارها
    if (selectedCity?.id == city.id) {
      selectedCity = null;
    } else {
      selectedCity = city;
    }
    notifyListeners();
  }

  void clearFilters() {
    selectedCity = null;
    minPriceController.clear();
    maxPriceController.clear();
    notifyListeners();
  }

  // تجميع البيانات لإرسالها
  // FilterCriteria getFilterCriteria() {
  //   double? min = double.tryParse(minPriceController.text);
  //   double? max = double.tryParse(maxPriceController.text);
  //   return FilterCriteria(
  //     cityId: selectedCity?.id,
  //     minPrice: min,
  //     maxPrice: max,
  //   );
  // }

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }
}

class FilterCriteria {
  final int? cityId;
  final double? minPrice;
  final double? maxPrice;

  FilterCriteria({this.cityId, this.minPrice, this.maxPrice});
}
