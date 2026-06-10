import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/cus_phone_field.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';
import 'package:ye_hraj/presentation/screens/common/common_view_model.dart';

import '../../../../../model/user_profile_model.dart';
import '../../../../custom_widgets/custom_bottom_sheet/custom_bottom_sheet_list.dart';
import '../../../../custom_widgets/custom_text.dart';
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

    // 3) صفر حالة الـ OTP ثم انتقل + ابدأ الإرسال بالتوازي
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
            Center(
              child: GestureDetector(
                onTap: registerViewModel.pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E8EF),
                        shape: BoxShape.circle,
                        image: registerViewModel.personalPhoto != null
                            ? DecorationImage(
                          image: FileImage(
                            registerViewModel.personalPhoto!,
                          ),
                          fit: BoxFit.cover,
                        )
                            : (widget.isEditing &&
                            registerViewModel.existingImageUrl !=
                                null &&
                            registerViewModel
                                .existingImageUrl!.isNotEmpty)
                            ? DecorationImage(
                          image: NetworkImage(
                            registerViewModel.existingImageUrl!,
                          ),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: (registerViewModel.personalPhoto == null &&
                          (registerViewModel.existingImageUrl == null ||
                              registerViewModel.existingImageUrl!.isEmpty))
                          ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.current.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (!widget.isEditing) ...[
              _buildLabel(context, 'اسم المستخدم', isRequired: true),
              _buildTextField(
                controller: registerViewModel.emailController,
                hint: 'أدخل اسم المستخدم',
                keyboardType: TextInputType.emailAddress,
                readOnly: widget.isEditing,
              ),
              const SizedBox(height: 16),
            ],

            _buildLabel(
              context,
              widget.isEditing ? 'كلمة المرور الجديدة' : 'كلمة المرور',
              isRequired: !widget.isEditing,
            ),
            _buildTextField(
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

            _buildLabel(context, 'اسمك الكامل', isRequired: true),
            _buildTextField(
              controller: registerViewModel.nameController,
              hint: 'محمد عبدالله',
            ),
            const SizedBox(height: 10),

            // ==========================================
            // 🔥 رقم الهاتف فقط (بدون OTP داخل الصفحة)
            // ==========================================
            // _buildLabel(context, 'رقم الهاتف', isRequired: true),
            CusPhoneField(
              onDropdownChanged: registerViewModel.setPhoneCountryCode,
              phoneCuntry: registerViewModel.phoneCuntry,
              onTextChanged: registerViewModel.setPhoneNumber,
              phoneHint: registerViewModel.phoneController != '7********' ? registerViewModel.phoneController : null,
              // controller: TextEditingController(text: registerViewModel.phoneController),
            ),

            const SizedBox(height: 10),
            _buildLabel(context, 'نبذة عنك (Bio)'),
            _buildTextField(
              controller: registerViewModel.bioController,
              hint: 'اكتب شيئاً عنك...',
              maxLines: 3,
            ),
            const SizedBox(height: 10),

            _buildLabel(context, 'المدينة', isRequired: false),
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

  Widget _buildLabel(
      BuildContext context,
      String text, {
        bool isRequired = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          CustomText(
            title: text,
            size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F162A),
          ),
          isRequired
              ? const Text(' *', style: TextStyle(color: Colors.red))
              : CustomText(
            title: '  (إختياري)  ',
            size: Theme.of(context).textTheme.bodySmall!.fontSize! - 3,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return CustomTextField(
      controller: controller,
      obscureText: obscureText,
      type: keyboardType,
      linesNumber: maxLines,
      readOnly: readOnly,
      hint: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }
}