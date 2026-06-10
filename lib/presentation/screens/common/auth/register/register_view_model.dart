import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../configurations/resources/strings_manager.dart';
import '../../../../../configurations/user_preferences.dart';
import '../../../../../model/cities_model.dart';
import '../../../../../model/region_model.dart';
import '../../../../../model/user_profile_model.dart';
import '../../../../custom_widgets/custom_text.dart';
import '../../../customer/profile/profile_view_model.dart';
import '../../common_view_model.dart';
import 'register_view_rep.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegistrationViewRepository _repo = RegistrationViewRepository();

  // --- Controllers ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // 🔥 متغيرات رقم الهاتف النصية
  String phoneController = '7********';
  String phoneCuntry = '+967';

  // 🔥 Controllers الخاص بـ OTP
  final TextEditingController otpController = TextEditingController();

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  // --- State Variables ---
  File? _personalPhoto;
  bool _isLoading = false;
  RegionModel? _selectedRegion;
  CitiesModel? _selectedCity;

  CitiesModel? get selectedCity => _selectedCity;
  RegionModel? get selectedRegion => _selectedRegion;

  String? existingImageUrl;
  bool isEditingMode = false;

  // 🔥 متغيرات الـ OTP
  String _originalPhone = '';
  bool _isPhoneVerified = false;
  bool _isOtpSent = false;
  bool _isOtpLoading = false;
  String? _verificationId;
  bool _wasPhoneNotEmpty = false;

  bool get isPhoneVerified => _isPhoneVerified;
  bool get isOtpSent => _isOtpSent;
  bool get isOtpLoading => _isOtpLoading;

  // --- Getters ---
  File? get personalPhoto => _personalPhoto;
  bool get isLoading => _isLoading;

  late CommonViewModel commonViewModel;

  // ==========================================
  // دوال التقاط رقم الهاتف والدولة
  // ==========================================

  void setPhoneCountryCode(String? code) {
    if (code == null) return;
    phoneCuntry = code;
    notifyListeners();
  }

  void setPhoneNumber(String? number) {
    if (number == null) return;
    phoneController = number;
    _onPhoneChanged();
    notifyListeners();
  }

  // 💡 الدالة الذكية لاكتشاف التعديل على الرقم
  void _onPhoneChanged() {
    String currentPhone = phoneController.trim();
    bool shouldNotify = false;

    if (currentPhone.isNotEmpty && !_wasPhoneNotEmpty) {
      _wasPhoneNotEmpty = true;
      shouldNotify = true;
    } else if (currentPhone.isEmpty && _wasPhoneNotEmpty) {
      _wasPhoneNotEmpty = false;
      shouldNotify = true;
    }

    if (isEditingMode) {
      if (currentPhone != _originalPhone && _isPhoneVerified) {
        _isPhoneVerified = false;
        _isOtpSent = false;
        shouldNotify = true;
      } else if (currentPhone == _originalPhone && !_isPhoneVerified) {
        _isPhoneVerified = true;
        _isOtpSent = false;
        shouldNotify = true;
      }
    } else {
      if (_isPhoneVerified || _isOtpSent) {
        _isPhoneVerified = false;
        _isOtpSent = false;
        shouldNotify = true;
      }
    }

    if (shouldNotify) notifyListeners();
  }

  Future<void> initData(
      BuildContext context,
      bool isEditing,
      UserProfileModel? userData,
      ) async {
    Future.microtask(() async {
      isEditingMode = isEditing;
      commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
      _clearData();

      if (commonViewModel.cities.isEmpty) {
        await commonViewModel.getAllCities(context);
      }

      if (isEditing && userData != null) {
        emailController.text = userData.email;
        nameController.text = userData.fullName;
        bioController.text = userData.bio ?? '';
        existingImageUrl = userData.profileImageUrl;

        if (userData.phoneNumber != null &&
            userData.phoneNumber!.contains('-')) {
          List<String> a = userData.phoneNumber!.split('-');
          phoneCuntry = a[0];
          phoneController = a[1];
        } else {
          phoneController = userData.phoneNumber ?? '';
        }

        _originalPhone = phoneController;
        _isPhoneVerified = true;

        if (!context.mounted) return;
        setCity(context, userData.cityId);
        setRegion(context, userData.regionId);
      }
      notifyListeners();
    });
  }

  // ==========================================
  // 🔥 التحقق من بيانات الفورم قبل الانتقال لصفحة الـ OTP
  // ==========================================
  bool validateRegistrationForm(BuildContext context) {
    if (!isEditingMode) {
      if (emailController.text.trim().isEmpty) {
        _showError(context, 'يرجى إدخال اسم المستخدم');
        return false;
      }
    }

    if (!isEditingMode && passwordController.text.isEmpty) {
      _showError(context, 'يرجى إدخال كلمة المرور');
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      _showError(context, 'يرجى إدخال الاسم الكامل');
      return false;
    }

    String phone = phoneController.trim();
    if (phone.isEmpty || phone == '7********') {
      _showError(context, 'يرجى إدخال رقم جوال صحيح');
      return false;
    }

    return true;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(
          size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
          title: message,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ==========================================
  // 🔥 إعادة ضبط حالة الـ OTP (تستدعى قبل فتح صفحة التحقق)
  // ==========================================
  void resetOtpState() {
    _isPhoneVerified = false;
    _isOtpSent = false;
    _isOtpLoading = false;
    _verificationId = null;
    otpController.clear();
    notifyListeners();
  }

  // ==========================================
  // 🔥 دوال الفايربيس (إرسال وتحقق OTP)
  // ==========================================

  Future<void> sendOtp(BuildContext context) async {
    String phone = phoneController.trim();
    String phoneCun = phoneCuntry.trim();

    if (phone.isEmpty || phone == '7********') {
      _showError(context, 'يرجى إدخال رقم هاتف صحيح');
      return;
    }

    _isOtpLoading = true;
    _isOtpSent = false;
    _isPhoneVerified = false;
    notifyListeners();

    await FirebaseAuth.instance.setLanguageCode('ar');

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '$phoneCun$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        _isPhoneVerified = true;
        _isOtpSent = true; // ✅ نبقيها true حتى تظهر الواجهة الصحيحة
        _isOtpLoading = false;
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
        _isOtpLoading = false;
        _isOtpSent = false;
        notifyListeners();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل الإرسال: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _isOtpSent = true;
        _isOtpLoading = false;
        notifyListeners();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال كود التحقق بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (otpController.text.trim().length < 6) {
      _showError(context, 'يرجى إدخال الرمز المكون من 6 أرقام');
      return;
    }

    _isOtpLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      _isPhoneVerified = true;
      _isOtpLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأكيد رقم الجوال بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _isOtpLoading = false;
      notifyListeners();
      if (context.mounted) {
        _showError(context, 'رمز التحقق غير صحيح');
      }
    }
  }

  // ==========================================
  // دوال البيانات الأساسية
  // ==========================================

  void _clearData() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController = '7********';
    phoneCuntry = '+967';
    bioController.clear();
    otpController.clear();
    _personalPhoto = null;
    _selectedCity = null;
    _selectedRegion = null;
    _isPhoneVerified = false;
    _isOtpSent = false;
    _isOtpLoading = false;
    _verificationId = null;
  }

  void setCity(BuildContext context, int? cityId) {
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    if (cityId == null) return;
    if (cityId.toString() == _selectedCity?.id.toString()) return;

    for (var cat in commonViewModel.cities) {
      if (cat.id.toString() == cityId.toString()) {
        _selectedCity = cat;
        break;
      }
    }
    _selectedRegion = null;
    commonViewModel.updateRegionsOfSelectedCity(context, cityId);
    notifyListeners();
  }

  void setRegion(BuildContext context, int? id) {
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    if (id == null) return;
    if (id.toString() == _selectedRegion?.id.toString()) return;

    for (var reg in commonViewModel.regions) {
      if (reg.id.toString() == id.toString()) {
        _selectedRegion = reg;
        break;
      }
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _personalPhoto = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> register(BuildContext context) async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showError(
          context, 'البريد، كلمة المرور، والمدينة حقول إجبارية!');
      return;
    }

    _isLoading = true;
    notifyListeners();

    bool isSuccess = await _repo.registerUser(
      context: context,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      phoneNumber: '$phoneCuntry-${phoneController.trim()}',
      bio: bioController.text.trim(),
      cityId: _selectedCity?.id,
      regionId: _selectedRegion?.id,
      personalPhoto: _personalPhoto,
    );

    _isLoading = false;
    notifyListeners();

    if (!context.mounted) return;

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(size: 14, title: 'تم إنشاء الحساب بنجاح! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      // 🔥 إغلاق صفحة الـ OTP وصفحة التسجيل معاً
      Navigator.of(context).pop();
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(size: 14, title: 'حدث خطأ أثناء التسجيل.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    String currentUserId = await UserPreferences()
        .getString(key: AppStrings.userIdKey, defaultValue: '');

    bool isSuccess = await _repo.updateUserProfile(
      userId: currentUserId,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      phoneNumber: '$phoneCuntry-${phoneController.trim()}',
      bio: bioController.text.trim(),
      cityId: _selectedCity?.id,
      regionId: _selectedRegion?.id,
      personalPhoto: _personalPhoto,
    );

    if (!isSuccess) {
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(size: 14, title: 'حدث خطأ أثناء التحديث.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    } else {
      await UserPreferences().saveString(
          key: AppStrings.userNameKey, value: nameController.text.trim());
      await UserPreferences().saveString(
          key: AppStrings.userEmailKey, value: emailController.text.trim());

      if (!context.mounted) return;

      ProfileViewModel profileVM =
      Provider.of<ProfileViewModel>(context, listen: false);
      profileVM.initData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              size: 14, title: 'تم تحديث الملف الشخصي بنجاح! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
    otpController.dispose();
    super.dispose();
  }
}