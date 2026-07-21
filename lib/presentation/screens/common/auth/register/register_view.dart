import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/cus_phone_field.dart';
import 'package:ye_hraj/presentation/screens/common/common_view_model.dart';

import '../../../../../model/user_profile_model.dart';
import '../../../../custom_widgets/custom_bottom_sheet/custom_bottom_sheet_list.dart';
import '../../../../custom_widgets/custom_text.dart';
import 'custom_widgets/auth_field_label.dart';
import 'custom_widgets/auth_text_field.dart';
import 'custom_widgets/profile_image_picker.dart';
import 'phoneVirev.dart';
import 'register_view_model.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/RegisterScreen';
  final bool isEditing;
  final UserProfileModel? existingUserData;

  const RegisterScreen({
    super.key,
    this.isEditing = false,
    this.existingUserData,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late CommonViewModel commonViewModel;
  late RegisterViewModel registerViewModel;

  @override
  void initState() {
    super.initState();
    registerViewModel = Provider.of<RegisterViewModel>(context, listen: false);
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    _init();
  }

  Future<void> _init() async {
    await registerViewModel.initData(
      context,
      widget.isEditing,
      widget.existingUserData,
    );
  }

  // 🔥 الانتقال لصفحة تأكيد الـ OTP
  Future<void> _goToOtpScreen() async {
    // 1) تحقق من الفالديشن
    if (!registerViewModel.validateRegistrationForm(context)) return;

    // 2) حالة التعديل بدون تغيير الرقم → سجّل مباشرة بدون OTP
    if (widget.isEditing && registerViewModel.isPhoneVerified) {
      await registerViewModel.updateProfile(context);
      return;
    }

    // 🇾🇪 الأرقام اليمنية (+967): تخطّي التحقق بالـ OTP والتسجيل مباشرة.
    //    (مؤقت لحين تغيير طريقة التحقق للأرقام اليمنية لاحقاً.)
    if (registerViewModel.isYemeniNumber) {
      registerViewModel.markPhoneVerifiedWithoutOtp();
      if (widget.isEditing) {
        await registerViewModel.updateProfile(context);
      } else {
        await registerViewModel.register(context);
      }
      return;
    }

    // 3) باقي الدول: صفّر حالة الـ OTP ثم انتقل + ابدأ الإرسال بالتوازي
    registerViewModel.resetOtpState();

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: registerViewModel,
          child: OtpVerificationScreen(isEditing: widget.isEditing),
        ),
      ),
    );

    // 4) أرسل الـ OTP بعد فتح الصفحة (الصفحة الجديدة ستعرض حالة "جاري الإرسال")
    registerViewModel.sendOtp(context);
  }

  @override
  Widget build(BuildContext context) {
    commonViewModel = Provider.of<CommonViewModel>(context);
    registerViewModel = Provider.of<RegisterViewModel>(context);

    // عنوان الزر السفلي
    final bool editingUnchangedPhone =
        widget.isEditing && registerViewModel.isPhoneVerified;
    final String bottomBtnTitle = editingUnchangedPhone
        ? 'حفظ التعديلات'
        : 'التالي';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: CustomText(
          title: widget.isEditing ? 'تعديل الملف الشخصي' : 'إنشاء حساب جديد',
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. اختيار الصورة الشخصية ---
            ProfileImagePicker(
              onTap: registerViewModel.pickImage,
              personalPhoto: registerViewModel.personalPhoto,
              existingImageUrl:
                  widget.isEditing ? registerViewModel.existingImageUrl : null,
            ),

            const SizedBox(height: 20),

            if (!widget.isEditing) ...[
              const AuthFieldLabel(text: 'اسم المستخدم', isRequired: true),
              AuthTextField(
                controller: registerViewModel.emailController,
                hint: 'أدخل اسم المستخدم',
                keyboardType: TextInputType.emailAddress,
                readOnly: widget.isEditing,
              ),
              const SizedBox(height: 16),
            ],

            AuthFieldLabel(
              text: widget.isEditing ? 'كلمة المرور الجديدة' : 'كلمة المرور',
              isRequired: !widget.isEditing,
            ),
            AuthTextField(
              controller: registerViewModel.passwordController,
              hint: widget.isEditing
                  ? 'اتركه فارغاً إذا لم ترد تغييره'
                  : '••••••••',
              obscureText: !registerViewModel.isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  registerViewModel.isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: const Color(0xFF9CA2AE),
                ),
                onPressed: () => registerViewModel.togglePasswordVisibility(),
                splashRadius: 20,
              ),
            ),
            const SizedBox(height: 10),

            const AuthFieldLabel(text: 'اسمك الكامل', isRequired: true),
            AuthTextField(
              controller: registerViewModel.nameController,
              hint: 'محمد عبدالله',
            ),
            const SizedBox(height: 10),

            // ==========================================
            // 🔥 رقم الهاتف فقط (بدون OTP داخل الصفحة)
            // ==========================================
            CusPhoneField(
              onDropdownChanged: registerViewModel.setPhoneCountryCode,
              phoneCuntry: registerViewModel.phoneCuntry,
              onTextChanged: registerViewModel.setPhoneNumber,
              phoneHint: registerViewModel.phoneController != '7********' ? registerViewModel.phoneController : null,
              // controller: TextEditingController(text: registerViewModel.phoneController),
            ),

            const SizedBox(height: 10),
            const AuthFieldLabel(text: 'نبذة عنك (Bio)'),
            AuthTextField(
              controller: registerViewModel.bioController,
              hint: 'اكتب شيئاً عنك...',
              maxLines: 3,
            ),
            const SizedBox(height: 10),

            const AuthFieldLabel(text: 'المدينة', isRequired: true),
            CustomBottomSheetWithSearch(
              cotx: context,
              bottomSheetTitle: 'اختر المدينة',
              hint: registerViewModel.selectedCity?.name ?? 'اختر المدينة',
              listOfItems: commonViewModel.cities,
              onItemTap: (
                  String? name,
                  int? id, {
                    int? indexOfSelectedItem,
                    dynamic selectedItem,
                  }) {
                Navigator.pop(context);
                registerViewModel.setCity(context, id);
              },
            ),
            const SizedBox(height: 10),

            const AuthFieldLabel(text: 'المنطقة', isRequired: true),
            CustomBottomSheetWithSearch(
              cotx: context,
              bottomSheetTitle: 'اختر المنطقة',
              hint: registerViewModel.selectedRegion?.name ?? 'اختر المنطقة',
              listOfItems: commonViewModel.regions,
              isLoading: commonViewModel.isLoadingRegion,
              onItemTap: (
                  String? name,
                  int? id, {
                    int? indexOfSelectedItem,
                    dynamic selectedItem,
                  }) {
                Navigator.pop(context);
                registerViewModel.setRegion(context, id);
              },
            ),

            const SizedBox(height: 20),

            // --- 4. زر "التالي" أو "حفظ التعديلات" (في حال تعديل بدون تغيير الرقم) ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                registerViewModel.isLoading ? null : _goToOtpScreen,
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
                  title: bottomBtnTitle,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}