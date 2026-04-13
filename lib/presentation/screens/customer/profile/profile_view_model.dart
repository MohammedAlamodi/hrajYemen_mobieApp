import 'package:flutter/material.dart';
import '../../../../configurations/resources/strings_manager.dart';
import '../../../../configurations/user_preferences.dart';
import '../../../../model/pay_commission_item_model.dart';
import '../../../../model/user_profile_model.dart';
import 'profile_repo.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();
  List<DynamicItemModel> promotedItems = [];

  UserProfileModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  UserProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // عند تهيئة الـ ViewModel، نقوم بجلب البيانات مباشرة
  Future<void> initData() async {
    Future.microtask(() => getUserData());
  }


  void loadPromotedItems() async {
    // هذه الدالة ذكية: تجيب من النت وتحدث الكاش، او تجيب من الكاش اذا النت مقطوع
    promotedItems = await _repo.getCommissionPayItems();
    notifyListeners();
  }

  /// دالة جلب البيانات من السيرفر
  Future<void> getUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.fetchUserProfile();

      if (result != null) {
        _userProfile = result;

        await UserPreferences().saveString(key: AppStrings.userProfileImageUrlKey , value: _userProfile?.profileImageUrl ?? ''); // حفظ البيانات في الشيرد بريفرنس



        notifyListeners();
      } else {
        _errorMessage = "لم نتمكن من جلب بيانات الحساب.";
      }
    } catch (e) {
      _errorMessage = "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  

  /// تفريغ البيانات (عند تسجيل الخروج مثلاً)
  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }
}