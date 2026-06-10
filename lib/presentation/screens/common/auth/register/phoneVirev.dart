import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';

import '../../../../custom_widgets/custom_text.dart';
import 'register_view_model.dart';

class OtpVerificationScreen extends StatefulWidget {
  static const String routeName = '/OtpVerificationScreen';
  final bool isEditing;

  const OtpVerificationScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late RegisterViewModel registerViewModel;

  @override
  Widget build(BuildContext context) {
    registerViewModel = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: CustomText(
          title: 'تأكيد رقم الجوال',
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // أيقونة الجوال
            Icon(
              Icons.phone_iphone_rounded,
              size: 80,
              color: AppColors.current.primary,
            ),
            const SizedBox(height: 20),

            // عنوان فرعي
            Center(
              child: CustomText(
                title: 'تم إرسال رمز التحقق إلى',
                fontWeight: FontWeight.w600,
                size: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: CustomText(
                title:
                '${registerViewModel.phoneCuntry} ${registerViewModel.phoneController}',
                fontWeight: FontWeight.bold,
                size: 18,
                color: AppColors.current.primary,
              ),
            ),

            const SizedBox(height: 40),

            // ==========================================
            // الحالة 1: جاري إرسال الرمز
            // ==========================================
            if (!registerViewModel.isOtpSent &&
                !registerViewModel.isPhoneVerified)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  CustomText(
                    title: 'جاري إرسال رمز التحقق...',
                    size: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),

            // ==========================================
            // الحالة 2: تم إرسال الرمز → أدخل الرمز
            // ==========================================
            if (registerViewModel.isOtpSent &&
                !registerViewModel.isPhoneVerified) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
                child: CustomText(
                  title: 'أدخل رمز التحقق',
                  fontWeight: FontWeight.w800,
                  size: 14,
                  color: const Color(0xFF0F162A),
                ),
              ),
              CustomTextField(
                controller: registerViewModel.otpController,
                type: TextInputType.number,
                hint: 'الرمز المكون من 6 أرقام',
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              const SizedBox(height: 20),

              // زر التحقق
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: registerViewModel.isOtpLoading
                      ? null
                      : () => registerViewModel.verifyOtp(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: registerViewModel.isOtpLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : CustomText(
                    title: 'تحقق من الرمز',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // إعادة الإرسال
              Center(
                child: TextButton(
                  onPressed: registerViewModel.isOtpLoading
                      ? null
                      : () => registerViewModel.sendOtp(context),
                  child: CustomText(
                    title: 'إعادة إرسال الرمز',
                    color: AppColors.current.primary,
                    fontWeight: FontWeight.bold,
                    size: 14,
                  ),
                ),
              ),
            ],

            // ==========================================
            // الحالة 3: تم تأكيد الرقم → زر التسجيل
            // ==========================================
            if (registerViewModel.isPhoneVerified) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  CustomText(
                    title: 'تم تأكيد رقم الجوال بنجاح',
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: registerViewModel.isLoading
                      ? null
                      : () async {
                    if (widget.isEditing) {
                      await registerViewModel.updateProfile(context);
                    } else {
                      await registerViewModel.register(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: registerViewModel.isLoading
                        ? Colors.grey
                        : AppColors.current.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: registerViewModel.isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : CustomText(
                    title: widget.isEditing
                        ? 'حفظ التعديلات'
                        : 'تسجيل الحساب',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}