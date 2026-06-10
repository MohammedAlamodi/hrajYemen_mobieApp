import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ye_hraj/presentation/screens/common/auth/register/register_view_rep.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final RegistrationViewRepository _repo = RegistrationViewRepository();

  // Controllers
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // State
  String phoneController = '';
  String phoneCountryCode = '+967';

  // 🔥 حالات الـ OTP (مطابقة للـ RegisterViewModel)
  bool _isOtpSent = false;
  bool _isOtpLoading = false;
  bool _isPhoneVerified = false;
  String? _verificationId;

  bool get isOtpSent => _isOtpSent;
  bool get isOtpLoading => _isOtpLoading;
  bool get isPhoneVerified => _isPhoneVerified;

  bool isPasswordVisible = false;
  bool isUpdatingLoading = false;

  void setPhoneNumber(String? number) {
    if (number == null) return;
    phoneController = number;
    // _onPhoneChanged(); // 🔥 نستدعي دالة الفحص هنا بدلاً من الـ listener!
    notifyListeners();
  }

  // 💡 الدالة الذكية لاكتشاف التعديل على الرقم
  // void _onPhoneChanged() {
  //   String currentPhone = phoneController.trim();
  //   bool shouldNotify = false;
  //
  //   if (currentPhone.isNotEmpty && !_wasPhoneNotEmpty) {
  //     _wasPhoneNotEmpty = true;
  //     shouldNotify = true;
  //   } else if (currentPhone.isEmpty && _wasPhoneNotEmpty) {
  //     _wasPhoneNotEmpty = false;
  //     shouldNotify = true;
  //   }
  //
  //   if (isEditingMode) {
  //     if (currentPhone != _originalPhone && _isPhoneVerified) {
  //       _isPhoneVerified = false;
  //       _isOtpSent = false;
  //       shouldNotify = true;
  //     } else if (currentPhone == _originalPhone && !_isPhoneVerified) {
  //       _isPhoneVerified = true;
  //       _isOtpSent = false;
  //       shouldNotify = true;
  //     }
  //   } else {
  //     if (_isPhoneVerified || _isOtpSent) {
  //       _isPhoneVerified = false;
  //       _isOtpSent = false;
  //       shouldNotify = true;
  //     }
  //   }
  //
  //   if (shouldNotify) notifyListeners();
  // }

  void setPhoneCountryCode(String? code) {
    if (code == null) return;
    phoneCountryCode = code;
    notifyListeners();
  }


  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  // 🔥 إرسال الرمز (Firebase OTP) - منسوخ ومعدل من الـ Register
  Future<void> sendOtp(BuildContext context) async {
    String phone = phoneController.trim();
    String phoneCun = phoneCountryCode.trim();

    if (phone.isEmpty || phone == '7********') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم هاتف صحيح'), backgroundColor: Colors.red),
      );
      return;
    }

    _isOtpLoading = true;
    notifyListeners();

    await FirebaseAuth.instance.setLanguageCode('ar');

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '$phoneCun$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        _isPhoneVerified = true;
        _isOtpSent = false;
        _isOtpLoading = false;
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
        _isOtpLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الإرسال: ${e.message}'), backgroundColor: Colors.red),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _isOtpSent = true;
        _isOtpLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال كود التحقق بنجاح'), backgroundColor: Colors.green),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // 🔥 التحقق من الرمز (Firebase OTP) - منسوخ ومعدل من الـ Register
  Future<void> verifyOtp(BuildContext context) async {
    if (otpController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الرمز المكون من 6 أرقام'), backgroundColor: Colors.red),
      );
      return;
    }

    _isOtpLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );

      // التحقق من صحة الكود عبر تسجيل دخول مؤقت
      await FirebaseAuth.instance.signInWithCredential(credential);

      _isPhoneVerified = true;
      _isOtpSent = false;
      _isOtpLoading = false;
      notifyListeners();

    } catch (e) {
      _isOtpLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز التحقق غير صحيح'), backgroundColor: Colors.red),
      );
    }
  }

  // 🔥 تحديث كلمة المرور النهائية عبر الـ API
  Future<bool> resetPassword(BuildContext context) async {
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال كلمة المرور الجديدة')));
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمات المرور غير متطابقة')));
      return false;
    }

    isUpdatingLoading = true;
    notifyListeners();

    try {
      // إرسال الرقم بنفس الصيغة التي يقبلها السيرفر في مشروعك (CountryCode-Phone)
      final bool success = await _repo.resetPassword(
        phone: '$phoneCountryCode-${phoneController.trim()}',
        newPassword: passwordController.text,
      );
      return success;
    } catch (e) {
      debugPrint("Reset Password Error: $e");
      return false;
    } finally {
      isUpdatingLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}