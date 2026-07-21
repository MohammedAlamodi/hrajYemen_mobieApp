import 'package:flutter/material.dart';
import 'package:ye_hraj/model/cities_model.dart';
import '../../../configurations/localization/i18n.dart';
import '../../../configurations/user_preferences.dart';
import '../../../configurations/resources/strings_manager.dart';
import 'package:dio/dio.dart';

import '../../../model/category_model.dart';
import '../../../model/region_model.dart';
import '../customer/home/home_repo.dart';
import 'common_rep.dart';

class CommonViewModel extends ChangeNotifier {
  final CommonViewRepository _repo = CommonViewRepository();

  String locale = 'ar';

  String indexOfSelectedLang = 'ar';

  bool _isLoading = false;

  OverlayEntry? overlayEntry;

  bool _isGetNotificationsLoading = false;

  bool _isFilterCatLoading = false;

  String? homePageErrorMessage;

  bool get isLoading => _isLoading;

  bool get isGetNotificationsLoading => _isGetNotificationsLoading;

  bool get isFilterCatLoading => _isFilterCatLoading;

  bool _isLoggedIn = false; // غيّرها لـ false لتجربة وضع الزائر

  bool get isLoggedIn => _isLoggedIn;

  void deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب', textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد؟ سيتم حذف جميع بياناتك وإعلاناتك نهائياً.', textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تراجع')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              UserPreferences().logout(context);
              // logout(context); // تنفيذ الحذف ثم الخروج
            },
            child: const Text('حذف نهائي', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  int newNotifications = 0;

  int indexOfCatMnu = 0;

  int currentIndex = 0;

  String currentUserId = '';
  String currentUserName = '';

  bool changeCurrentIndex = false;


  // القوائم والبيانات
  List<CategoryModel> _categoriesList = []; // القائمة الخام من الموديل
  List<SubCategoryModel> _subCategoriesList = []; // القائمة الفرعية الحالية

  List<CategoryModel> get categoriesList => _categoriesList;

  List<SubCategoryModel> get subCategories => _subCategoriesList;

  bool _isLoadingCategories = false;
  bool _isLoadingSubCategories = false;
  bool _isLoadingRegion = false;

  bool get isLoadingCategories => _isLoadingCategories;

  bool get isLoadingRegion => _isLoadingRegion;

  bool get isLoadingSubCategories => _isLoadingSubCategories;

  final HomeRepository _homeRepo = HomeRepository();

  changeHomeIndex(int val) {
    currentIndex = val;
    changeCurrentIndex = false;
    notifyListeners();
  }

  List<CitiesModel> cities = [];
  List<RegionModel> regions = [];

  /// حارس لمنع إطلاق أكثر من طلب لجلب المدن في نفس الوقت.
  bool _isLoadingCities = false;

  bool get isLoadingCities => _isLoadingCities;

  /// هل تم تحميل المدن بنجاح؟
  bool get hasCities => cities.isNotEmpty;

  /// تتأكد من توفّر المدن: إن كانت محمّلة مسبقاً لا تفعل شيئاً،
  /// وإن لم تكن محمّلة (ولا يوجد طلب جارٍ) ترسل طلباً لجلبها.
  /// تُرجع true عندما تصبح المدن متوفّرة.
  Future<bool> ensureCitiesLoaded(BuildContext context) async {
    if (hasCities) return true;
    if (_isLoadingCities) return false;
    await getAllCities(context);
    return hasCities;
  }

   Future<void> getAllCities(BuildContext context) async {
    if (_isLoadingCities) return; // تجنّب الطلبات المتزامنة المكرّرة
    _isLoadingCities = true;
    _isLoading = true;
    notifyListeners();

    try {
      cities = await _repo.fetchCities();
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage =
            e.response?.data['message'] ?? 'An error occurred';
        debugPrint('error message1 $errorMessage');
        homePageErrorMessage = 'Error : $errorMessage ';
      } else {
        String errorMessage = 'Network error: ${e.message}';
        debugPrint('error in login $errorMessage');
        homePageErrorMessage = 'Error in Server';
      }
    } catch (e) {
      debugPrint('***********error in login ${e.toString()}');
      homePageErrorMessage = S.of(context)!.anErrorOccurred;
    }

    _isLoadingCities = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRegionsOfSelectedCity(BuildContext context, int cityId) async {
    _isLoadingRegion = true;
    notifyListeners();

    try {
      regions = (await _repo.fetchRegion(cityId));
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage =
            e.response?.data['message'] ?? 'An error occurred';
        debugPrint('error message1 $errorMessage');
        homePageErrorMessage = 'Error : $errorMessage ';
        // await showErrorDialog(context: context, message: S.of(context)!.errorHap
        //     , description: errorMessage);
      } else {
        String errorMessage = 'Network error: ${e.message}';
        debugPrint('error in login $errorMessage');
        homePageErrorMessage = 'Error in Server';
      }
    } catch (e) {
      debugPrint('***********error in login ${e.toString()}');
      homePageErrorMessage = S.of(context)!.anErrorOccurred;
    }

    _isLoadingRegion = false;
    notifyListeners();
  }

  changeLanguage(String val) {
    locale = val;
    indexOfSelectedLang = val;
    notifyListeners();
  }

  Future getLanguage() async {
    UserPreferences userPreferences = UserPreferences();

    locale = await userPreferences.getString(
        key: AppStrings.languageKey, defaultValue: 'ar');

    notifyListeners();
  }

  void setLoginIn(bool val) {
    _isLoggedIn = val;
    notifyListeners();
  }

  /// تصفير كل حالة المستخدم في الذاكرة (تُستدعى عند تسجيل الخروج أو الدخول كزائر).
  /// تضمن أن لا تبقى أي بيانات خاصة بالمستخدم السابق (شات/بروفايل/مفضلة...الخ).
  void clearUserSession() {
    _isLoggedIn = false;
    currentUserId = '';
    currentUserName = '';
    newNotifications = 0;
    currentIndex = 0;
    notifyListeners();
  }

  void setCurrentUserId(String val) {
    currentUserId = val;
    notifyListeners();
  }
  void setCurrentUserName(String val) {
    currentUserName = val;
    notifyListeners();
  }


  Future<void> fetchCategoriesFromRepo() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      // نستخدم الدالة الموجودة مسبقاً في الريبو
      _categoriesList = await _homeRepo.fetchCategories();
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> updateSubCategories(int? mainCategoryId) async {
    _isLoadingSubCategories = true;
    notifyListeners();
    _subCategoriesList = [];

    if (mainCategoryId == null) {
      _subCategoriesList = [];
    } else {
      _subCategoriesList = await _homeRepo.fetchSubCategories(mainCategoryId);
    }

    _isLoadingSubCategories = false;
    notifyListeners();
  }


  Future<void> initData({required BuildContext context}) async {
    await fetchCategoriesFromRepo();
    await getAllCities(context);
  }
}
