import 'package:flutter/material.dart';
import '../../../configurations/localization/i18n.dart';
import '../../../configurations/user_preferences.dart';
import '../../../configurations/resources/strings_manager.dart';
import 'package:dio/dio.dart';

import '../../../model/user_model.dart';
import '../../custom_widgets/dialog/overlay_helper.dart';
import 'common_rep.dart';

class CommonViewModel extends ChangeNotifier {
  // final CommonViewRepository _repo = CommonViewRepository();

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
  UserModel? _user;

  bool get isLoggedIn => _isLoggedIn;
  UserModel? get user => _user;

  ProfileViewModel() {
    _loadUserData();
  }

  void _loadUserData() {
    // محاكاة جلب البيانات
    if (_isLoggedIn) {
      _user = UserModel(
        id: '1',
        fullName: 'محمد عبدالله العمودي',
        userName:  'mo',
        location: 'المكلا',
        profileImageUrl: 'https://ymimg1.b8cdn.com/resized/car_model/11937/pictures/15965510/webp_listing_main_zeekr-001-exterior-01.webp', // رابط صورة افتراضي
        phoneNumber: '+967 738883773', // إعلاناتي الحالية
        bio: 'مرحبا! أنا مستخدم نشط في التطبيق.',
        activeAdsCount: 12, // إعلاناتي الحالية
        expiredAdsCount: 5,  // إعلاناتي المنتهية

      );
    }
    notifyListeners();
  }

  // تسجيل الدخول (محاكاة)
  Future<void> login() async{
    _isLoggedIn = true;
    _loadUserData();
    notifyListeners();
  }

  // تسجيل الخروج
  void logout(BuildContext context) {
    // هنا مسح التوكن والبيانات المحلية
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
    // Navigator.pushReplacementNamed(context, '/login');
  }

  // حذف الحساب (مهم لقوقل بلاي)
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
              logout(context); // تنفيذ الحذف ثم الخروج
            },
            child: const Text('حذف نهائي', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // List<UserRolesModel> userRoles = [];
  //
  // List<CustomerModel> customers = [];
  //
  // List<NotificationModel> notifications= [];
  int newNotifications = 0;
  //
  // List<OfferCategoryModel> allOffersCategorise = [];
  //
  // List<OfferModel> allUserOffers = [];
  // List<OfferModel> filteredUserOffers = [];

  int indexOfCatMnu = 0;

  int currentIndex = 0;

  bool changeCurrentIndex = false;

  changeHomeIndex(int val) {
    currentIndex = val;
    changeCurrentIndex = false;
    notifyListeners();
  }

  // changeLanguage(String val) {
  //   indexOfSelectedLang = val;
  //   notifyListeners();
  // }

  // resetData(){
  //   homePageErrorMessage = null;
  //   filteredUserOffers = allUserOffers;
  //   indexOfCatMnu = 0;
  //   notifyListeners();
  // }

  changeLanguage(String val) {
    locale = val;
    indexOfSelectedLang = val;
    notifyListeners();
  }

  Future getLanguage() async {
    UserPreferences userPreferences = UserPreferences();

    locale = userPreferences.getString(
        key: AppStrings.languageKey, defaultValue: 'ar');

    notifyListeners();
  }

  void setLoginIn(bool val) {
    _isLoggedIn = val;
    notifyListeners();
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
