import 'package:flutter/material.dart';
import 'package:ye_hraj/model/cities_model.dart';
import '../../../configurations/localization/i18n.dart';
import '../../../configurations/user_preferences.dart';
import '../../../configurations/resources/strings_manager.dart';
import 'package:dio/dio.dart';

import '../../../model/category_model.dart';
import '../../../model/region_model.dart';
import '../../../model/user_model.dart';
import '../../custom_widgets/dialog/overlay_helper.dart';
import '../home/home_repo.dart';
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

  late String currentUserId;
  late String currentUserName;

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

   Future<void> getAllCities(BuildContext context) async {
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

  // Future<void> getUseRoles(BuildContext context) async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   userRoles = [
  //     UserRolesModel(id: 1,roleID: 'id',name: 'Bank',userCount: 'null',claimCount: 'null'),
  //     UserRolesModel(id: 1,roleID: 'id',name: 'Customer',userCount: 'null',claimCount: 'null'),
  //     UserRolesModel(id: 1,roleID: 'id',name: 'Seller',userCount: 'null',claimCount: 'null'),
  //   ];
  //   // try {
  //   //   userRoles = (await _repo.getUseRoles(context));
  //   // } on DioException catch (e) {
  //   //   if (e.response != null) {
  //   //     String errorMessage =
  //   //         e.response?.data['message'] ?? 'An error occurred';
  //   //     debugPrint('error message1 $errorMessage');
  //   //     // await showErrorDialog(context: context, message: S.of(context)!.errorHap
  //   //     //     , description: errorMessage);
  //   //   } else {
  //   //     String errorMessage = 'Network error: ${e.message}';
  //   //     debugPrint('error in login $errorMessage');
  //   //   }
  //   // } catch (e) {
  //   //   debugPrint('***********error in login ${e.toString()}');
  //   //   OverlayHelper.showErrorToast(context, S.of(context)!.anErrorOccurred);
  //   // }
  //   _isLoading = false;
  //   notifyListeners();
  // }

  // Future<void> getOffersCategorise(BuildContext context) async {
  //   // _isLoading = true;
  //   // notifyListeners();
  //
  //   homePageErrorMessage = null;
  //   try {
  //     var list = (await _repo.getOfferCategorise(context));
  //     allOffersCategorise
  //         .add(OfferCategoryModel(categoryID: 0, name: S.of(context)!.all));
  //     for (OfferCategoryModel i in list) {
  //       allOffersCategorise.add(i);
  //     }
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       String errorMessage =
  //           e.response?.data['message'] ?? 'An error occurred';
  //       debugPrint('error message1 $errorMessage');
  //       homePageErrorMessage = 'Error : $errorMessage ';
  //       // await showErrorDialog(context: context, message: S.of(context)!.errorHap
  //       //     , description: errorMessage);
  //     } else {
  //       String errorMessage = 'Network error: ${e.message}';
  //       debugPrint('error in login $errorMessage');
  //       homePageErrorMessage = 'Error in Server';
  //     }
  //   } catch (e) {
  //     debugPrint('***********error in login ${e.toString()}');
  //     homePageErrorMessage = S.of(context)!.anErrorOccurred;
  //   }
  //   // _isLoading = false;
  //   // notifyListeners();
  // }
  //
  // Future<void> getOffers(BuildContext context) async {
  //   // _isLoading = true;
  //   // notifyListeners();
  //
  //   homePageErrorMessage = null;
  //   try {
  //     allUserOffers = (await _repo.getOffers(context));
  //     filteredUserOffers = allUserOffers;
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       String errorMessage =
  //           e.response?.data['message'] ?? 'An error occurred';
  //       debugPrint('error message1 $errorMessage');
  //       homePageErrorMessage = 'Error : $errorMessage ';
  //       // await showErrorDialog(context: context, message: S.of(context)!.errorHap
  //       //     , description: errorMessage);
  //     } else {
  //       String errorMessage = 'Network error: ${e.message}';
  //       debugPrint('error in getOffers1 $errorMessage');
  //       homePageErrorMessage = 'Error in Server';
  //     }
  //   } catch (e) {
  //     debugPrint('***********error in getOffers2 ${e.toString()}');
  //     homePageErrorMessage = S.of(context)!.anErrorOccurred;
  //   }
  //   // _isLoading = false;
  //   // notifyListeners();
  // }
  //
  // Future<void> getNotifications(BuildContext context) async {
  //   _isGetNotificationsLoading = true;
  //   notifyListeners();
  //
  //   notifications = [];
  //   newNotifications = 0;
  //
  //   try {
  //     notifications = (await _repo.getNotifications(context));
  //
  //     for (var i in notifications){
  //       if(i.isRead == false){
  //         newNotifications ++;
  //       }
  //     }
  //
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       String errorMessage =
  //           e.response?.data['message'] ?? 'An error occurred';
  //       debugPrint('error message1 $errorMessage');
  //       homePageErrorMessage = 'Error : $errorMessage ';
  //       // await showErrorDialog(context: context, message: S.of(context)!.errorHap
  //       //     , description: errorMessage);
  //     } else {
  //       String errorMessage = 'Network error: ${e.message}';
  //       debugPrint('error in getOffers1 $errorMessage');
  //       homePageErrorMessage = S.of(context)!.anErrorOccurred;
  //     }
  //   } catch (e) {
  //     debugPrint('***********error in getOffers2 ${e.toString()}');
  //     homePageErrorMessage = S.of(context)!.anErrorOccurred;
  //   }
  //   _isGetNotificationsLoading = false;
  //   notifyListeners();
  // }
  //
  // Future<void> getCustomers(BuildContext context) async {
  //   // _isLoading = true;
  //   // notifyListeners();
  //
  //   homePageErrorMessage = null;
  //   try {
  //     customers = await _repo.getCustomers(context);
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       String errorMessage =
  //           e.response?.data['message'] ?? 'An error occurred';
  //       debugPrint('error message1 $errorMessage');
  //       homePageErrorMessage = 'Error : $errorMessage ';
  //       // await showErrorDialog(context: context, message: S.of(context)!.errorHap
  //       //     , description: errorMessage);
  //     } else {
  //       String errorMessage = 'Network error: ${e.message}';
  //       debugPrint('error in getOffers1 $errorMessage');
  //       homePageErrorMessage = 'Error in Server';
  //     }
  //   } catch (e) {
  //     debugPrint('***********error in getOffers2 ${e.toString()}');
  //     homePageErrorMessage = S.of(context)!.anErrorOccurred;
  //   }
  //   // _isLoading = false;
  //   // notifyListeners();
  // }
  //
  // Future<void> getOffersByBank(BuildContext context, int bankId) async {
  //   // _isLoading = true;
  //   // notifyListeners();
  //
  //   homePageErrorMessage = null;
  //   try {
  //     allUserOffers = (await _repo.getOffersByBank(context, bankId));
  //     filteredUserOffers = allUserOffers;
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       String errorMessage =
  //           e.response?.data['message'] ?? 'An error occurred';
  //       debugPrint('error message1 $errorMessage');
  //       homePageErrorMessage = 'Error : $errorMessage ';
  //       // await showErrorDialog(context: context, message: S.of(context)!.errorHap
  //       //     , description: errorMessage);
  //     } else {
  //       String errorMessage = 'Network error: ${e.message}';
  //       debugPrint('error in getOffers1 $errorMessage');
  //       homePageErrorMessage = 'Error in Server';
  //     }
  //   } catch (e) {
  //     debugPrint('***********error in getOffers2 ${e.toString()}');
  //     homePageErrorMessage = S.of(context)!.anErrorOccurred;
  //   }
  //   // _isLoading = false;
  //   // notifyListeners();
  // }

  // Future<void> getCustomerHomePageData(context) async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   await getOffers(context);
  //   await getOffersCategorise(context);
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
  //
  // Future<void> getBankHomePageData(context) async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   await getCustomers(context);
  //   await getOffersCategorise(context);
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
  //
  // void filterOffers(String query) {
  //   final filter = allUserOffers.where((offer) {
  //     final offerNameLower = offer.foreignName!.toLowerCase();
  //     final offerOwner = offer.ownerOfferName?.toLowerCase() ?? '';
  //     List<String> searchLowerSplit = query.toLowerCase().split(' ');
  //     int coun = 0;
  //     for (var i in searchLowerSplit) {
  //       if (offerNameLower.contains(i) || offerOwner.contains(i)) {
  //         coun++;
  //       }
  //     }
  //     if (coun == searchLowerSplit.length) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }).toList();
  //
  //   filteredUserOffers = filter;
  //
  //   notifyListeners();
  // }
  //
  // Future<void> filterOffersByCat(int index) async {
  //   _isFilterCatLoading = true;
  //   notifyListeners();
  //   filteredUserOffers = [];
  //
  //   indexOfCatMnu = index;
  //   debugPrint('index $index');
  //   if (index == 0) {
  //     filteredUserOffers = allUserOffers;
  //   } else {
  //     for (OfferModel o in allUserOffers) {
  //       if (o.categoryID.toString() ==
  //           allOffersCategorise[index].categoryID.toString()) {
  //         filteredUserOffers.add(o);
  //       }
  //     }
  //   }
  //
  //   await Future.delayed(Duration(seconds: 1));
  //
  //   _isFilterCatLoading = false;
  //   notifyListeners();
  // }
  //
  // Future<void> filterOffersByLoanAvailable(bool val,) async {
  //   _isFilterCatLoading = true;
  //   notifyListeners();
  //   List<OfferModel> list = filteredUserOffers;
  //
  //
  //   if(val){
  //     filteredUserOffers = [];
  //
  //     for (OfferModel o in list) {
  //       debugPrint('******o ${o.loanAvailable}');
  //       if (o.loanAvailable!) {
  //         filteredUserOffers.add(o);
  //       }
  //     }
  //   }else{
  //     // await filterOffersByCat(indexOfCatMnu);
  //   }
  //
  //   await Future.delayed(Duration(seconds: 1));
  //
  //   _isFilterCatLoading = false;
  //   notifyListeners();
  // }
}
