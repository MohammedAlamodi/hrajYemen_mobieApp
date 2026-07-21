import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ye_hraj/presentation/screens/common/common_rep.dart';
import '../../../../configurations/data/products_cache.dart';
import '../../../../model/category_model.dart';
import '../../../../model/cities_model.dart';
import '../../../../model/product_model.dart';
import '../../../../model/region_model.dart';
import 'home_repo.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();
  final CommonViewRepository _commRepo = CommonViewRepository();
  final ProductsCache _cache = ProductsCache();

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

  // --- دالة موحّدة لجلب المنتجات مع تطبيق كل الفلاتر النشطة ---
  // أي فلتر مفعّل (القسم/القسم الفرعي/المدينة/المنطقة/السعر/البحث)
  // يُرسل تلقائياً في جميع طلبات جلب المنتجات لضمان اتساق الفلترة.
  Future<List<ProductModel>> _fetchFilteredProducts({required int page}) {
    return _repo.fetchProducts(
      page: page,
      limit: _pageSize,
      categoryId: _selectedCategoryId,
      subCategoryId: _selectedSubCategoryId,
      search: sherTextCont.text,
      cityId: selectedCity?.id,
      regionId: selectedRegion?.id,
      minPrice: minPriceController.text.isNotEmpty
          ? double.tryParse(minPriceController.text)
          : null,
      maxPrice: maxPriceController.text.isNotEmpty
          ? double.tryParse(maxPriceController.text)
          : null,
    );
  }

  // هل يوجد أي فلتر نشط؟ (يُستخدم لتحديد متى نخزّن/نقرأ من الكاش)
  bool get _hasActiveFilters =>
      _selectedCategoryId != null ||
      _selectedSubCategoryId != null ||
      selectedCity != null ||
      selectedRegion != null ||
      sherTextCont.text.isNotEmpty ||
      minPriceController.text.isNotEmpty ||
      maxPriceController.text.isNotEmpty;

  // عدد فلاتر النافذة السفلية النشطة (للشارة الحمراء فوق زر الفلتر):
  // المدينة=1، المدينة+المنطقة=2، المدينة+المنطقة+السعر=3 ...
  int get activeFilterCount {
    int count = 0;
    if (selectedCity != null) count++;
    if (selectedRegion != null) count++;
    if (minPriceController.text.isNotEmpty ||
        maxPriceController.text.isNotEmpty) {
      count++;
    }
    return count;
  }

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

      _products = await _fetchFilteredProducts(page: _currentPage);
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
        _products = await _fetchFilteredProducts(page: _currentPage);
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
      final results = await _fetchFilteredProducts(page: _currentPage);

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

      _products = await _fetchFilteredProducts(page: _currentPage);

      _hasMoreData = _products.length >= _pageSize;
    } else {
      // تحديد القسم الفرعي وجلب منتجاته
      _selectedSubCategoryId = subCatId;

      _products = await _fetchFilteredProducts(page: _currentPage);
      _hasMoreData = _products.length >= _pageSize;
    }
    notifyListeners();
  }

  Future<void> getInitialData() async {
    final noFilters = !_hasActiveFilters;
    bool shownFromCache = false;

    // 1️⃣ أول دخول وبدون فلاتر: اعرض منتجات الكاش فوراً قبل انتظار السيرفر
    if (noFilters && _products.isEmpty) {
      final cached = await _cache.loadProducts();
      if (cached.isNotEmpty) {
        _products = cached;
        shownFromCache = true;
        notifyListeners();
      }
    }

    // نُظهر مؤشّر التحميل فقط إذا لم يكن لدينا أي بيانات نعرضها (لا كاش ولا منتجات)
    if (_categories.isEmpty && _products.isEmpty) {
      _isLoading = true;
    } else if (!shownFromCache && _products.isEmpty) {
      _isProductLoading = true;
    }
    notifyListeners();

    try {
      _currentPage = 1;
      // جلب المنتجات والفئات بالتوازي (لتحسين السرعة)
      final results = await Future.wait([
        _fetchFilteredProducts(page: _currentPage),
        _repo.fetchCategories(),
      ]);

      // 2️⃣ استبدال بيانات الكاش بأحدث بيانات من السيرفر (تحديث لحظي للواجهة)
      _products = results[0] as List<ProductModel>;
      _categories = results[1] as List<CategoryModel>;

      _hasMoreData = _products.length >= _pageSize;

      // 3️⃣ حفظ أحدث خلاصة في الكاش (فقط الخلاصة الافتراضية بدون فلاتر)
      if (noFilters) {
        await _cache.saveProducts(_products);
      }
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
      _products = await _fetchFilteredProducts(page: _currentPage);
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
      final newProducts = await _fetchFilteredProducts(page: _currentPage);

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

  // حالة المناطق (تُجلب عند اختيار مدينة)
  List<RegionModel> regions = [];
  bool isLoadingRegions = false;
  RegionModel? selectedRegion;

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

  // اختيار/إلغاء مدينة. عند الاختيار يتم جلب مناطق هذه المدينة وعرضها.
  Future<void> selectCity(CitiesModel city) async {
    // إذا ضغط على نفس المدينة المختارة: نلغي الاختيار ونمسح المناطق
    if (selectedCity?.id == city.id) {
      selectedCity = null;
      selectedRegion = null;
      regions = [];
      notifyListeners();
      return;
    }

    // اختيار مدينة جديدة: نصفّر المنطقة السابقة ونجلب مناطق المدينة الجديدة
    selectedCity = city;
    selectedRegion = null;
    regions = [];
    isLoadingRegions = true;
    notifyListeners();

    try {
      regions = await _commRepo.fetchRegion(city.id);
    } catch (e) {
      debugPrint("خطأ في جلب مناطق المدينة: $e");
      regions = [];
    } finally {
      isLoadingRegions = false;
      notifyListeners();
    }
  }

  // اختيار/إلغاء منطقة داخل المدينة المختارة
  void selectRegion(RegionModel region) {
    if (selectedRegion?.id == region.id) {
      selectedRegion = null;
    } else {
      selectedRegion = region;
    }
    notifyListeners();
  }

  void clearFilters() {
    selectedCity = null;
    selectedRegion = null;
    regions = [];
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
