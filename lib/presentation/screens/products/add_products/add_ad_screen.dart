import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_button.dart';
import 'package:ye_hraj/presentation/screens/profile/guest_screen.dart';
import '../../../../configurations/helpers_functions.dart';
import '../../common/common_view_model.dart';
import 'add_ad_step1_details.dart';
import 'add_ad_view_model.dart';

// استدعاء الخطوات الفرعية
import 'add_ad_step2_images.dart';
import 'add_ad_step3_contact.dart';
import 'add_ad_step4_review.dart';

class AddAdScreen extends StatefulWidget {
  AddAdScreen({super.key});

  @override
  State<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen> {
  late CommonViewModel commonViewModel;
  late AddAdViewModel addAdViewModel;

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    addAdViewModel = Provider.of<AddAdViewModel>(context, listen: false);
    await commonViewModel.initData(context: context);
  }

  @override
  Widget build(BuildContext context) {
    commonViewModel = Provider.of<CommonViewModel>(context);
    addAdViewModel = Provider.of<AddAdViewModel>(context);

    return !commonViewModel.isLoggedIn
        ? GuestScreen()
        : Scaffold(
            backgroundColor: AppColors.current.appBackground,
            body: SafeArea(
              child: Consumer<AddAdViewModel>(
                builder: (context, vm, child) {
                  return Column(
                    children: [
                      // 1. الهيدر المتغير
                      _buildHeader(context, vm),

                      // 2. المحتوى المتغير حسب الخطوة
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildCurrentStep(vm),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // 3. زر التنقل السفلي
            bottomNavigationBar: Consumer<AddAdViewModel>(
              builder: (context, vm, child) => Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE1E8EF))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      onTap: (vm.currentStep == 4 && !vm.isAgreeToPostAd)
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: CustomText(
                                    title:
                                        'يرجى الموافقة على اتفاقيه نشر الإعلان قبل المتابعة.',
                                    color: Colors.white,
                                    size:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall!.fontSize! -
                                        2,
                                  ),
                                ),
                              );
                            }
                          : () => vm.nextStep(context),
                      text: vm.currentStep == 4 ? 'نشر الإعلان' : 'التالي',

                      btnColor: (vm.currentStep == 4 && !vm.isAgreeToPostAd)
                          ? Colors.grey
                          : const Color(0xFF2462EB),
                      loading: vm.isLoadingPostAd,
                      btnTextColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildCurrentStep(AddAdViewModel vm) {
    switch (vm.currentStep) {
      case 1:
        return const AddAdStep1Details(); // الكود الذي عملناه سابقاً
      case 2:
        return const AddAdStep2Images();
      case 3:
        return const AddAdStep3Contact();
      case 4:
        return const AddAdStep4Review();
      default:
        return const SizedBox();
    }
  }

  Widget _buildHeader(BuildContext context, AddAdViewModel vm) {
    String title = 'إضافة إعلان جديد';
    if (vm.currentStep == 2) title = 'أضف صور الإعلان';
    if (vm.currentStep == 3) title = 'طرق التواصل';
    if (vm.currentStep == 4) title = 'مراجعة قبل النشر';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE1E8EF))),
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => vm.previousStep(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE1E8EF)),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: isTablet(context) ? 30 : 18,
                color: Colors.black,
              ),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),

                CustomText(title: title, size: 17, fontWeight: FontWeight.w800),

                SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomText(
                    title: '${vm.currentStep} من ${vm.totalSteps}',
                    size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF63748A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
