import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/cus_phone_field.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';

import 'forget_password_view_model.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const CustomText(title: 'استعادة الحساب', fontWeight: FontWeight.bold),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!vm.isPhoneVerified) ...[
                    // --- المرحلة الأولى: الهاتف والـ OTP ---
                    const CustomText(title: 'أدخل رقم الهاتف المرتبط بحسابك لتغيير كلمة المرور'),
                    const SizedBox(height: 20),
                    CusPhoneField(
                      onDropdownChanged: vm.setPhoneCountryCode,
                      onTextChanged: vm.setPhoneNumber,
                      phoneCuntry: vm.phoneCountryCode,
                    ),

                    const SizedBox(height: 16),

                    if (vm.isOtpSent) ...[
                      CustomTextField(
                        controller: vm.otpController,
                        hint: 'أدخل رمز التحقق (6 أرقام)',
                        type: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.current.primary),
                        onPressed: vm.isOtpLoading ? null : () {
                          if (vm.isOtpSent) {
                            vm.verifyOtp(context);
                          } else {
                            vm.sendOtp(context);
                          }
                        },
                        child: vm.isOtpLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : CustomText(title: vm.isOtpSent ? 'تحقق من الرمز' : 'إرسال رمز التأكيد', color: Colors.white),
                      ),
                    ),
                  ] else ...[
                    // --- المرحلة الثانية: تعيين كلمة السر الجديدة ---
                    const CustomText(title: 'تم التحقق! أدخل كلمة المرور الجديدة أدناه', fontWeight: FontWeight.bold, color: Colors.green,),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: vm.passwordController,
                      hint: 'كلمة المرور الجديدة',
                      obscureText: !vm.isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(vm.isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: vm.togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: vm.confirmPasswordController,
                      hint: 'تأكيد كلمة المرور الجديدة',
                      obscureText: !vm.isPasswordVisible,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.current.primary),
                        onPressed: vm.isUpdatingLoading ? null : () async {
                          bool success = await vm.resetPassword(context);
                          if (success) _showSuccessDialog(context);
                        },
                        child: vm.isUpdatingLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const CustomText(title: 'تحديث كلمة المرور', color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const CustomText(title: 'تم تحديث كلمة المرور بنجاح!', fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            const CustomText(title: 'يمكنك الآن تسجيل الدخول باستخدام كلمة المرور الجديدة', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.current.primary),
              onPressed: () {
                Navigator.pop(context); // إغلاق الديلوج
                Navigator.pop(context); // العودة لصفحة تسجيل الدخول
              },
              child: const CustomText(title: 'الانتقال لتسجيل الدخول', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}