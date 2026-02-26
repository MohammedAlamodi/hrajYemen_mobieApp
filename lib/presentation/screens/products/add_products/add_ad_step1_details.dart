import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/helpers_functions.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/configurations/resources/assets_manager.dart';
import 'package:ye_hraj/presentation/custom_widgets/cust_svg_icons.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_bottom_sheet/custom_bottom_sheet_list.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';
import 'package:ye_hraj/presentation/screens/common/common_view_model.dart';
import '../../../custom_widgets/custom_text.dart';
import 'add_ad_view_model.dart';

class AddAdStep1Details extends StatelessWidget {
  const AddAdStep1Details({super.key});

  @override
  Widget build(BuildContext context) {
    // استدعاء الـ ViewModel
    final vm = Provider.of<AddAdViewModel>(context);
    CommonViewModel commonViewModel = Provider.of<CommonViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. قسم التصنيف (الفئات) ---
        _buildSectionTitle(context, 'تصنيف الإعلان'),
        const SizedBox(height: 12),

        // الفئة الرئيسية (إجباري)
        _buildLabel(context, 'الفئة الرئيسية', isRequired: true),

        CustomBottomSheetWithSearch(
          cotx: context,
          bottomSheetTitle: 'اختر الفئة...',
          hint: vm.selectedMainCategory?.name ?? 'اختر الفئة...',
          listOfItems: commonViewModel.categoriesList,
          onItemTap:
              (
                String? name,
                int? id, {
                int? indexOfSelectedItem,
                dynamic selectedItem,
              }) {
                Navigator.pop(context);
                vm.setMainCategory(context, id);
              },
        ),

        // الفئة الفرعية (اختياري)
        const SizedBox(height: 16),

        _buildLabel(context, 'الفئة الفرعية (اختياري)', isRequired: false),

        CustomBottomSheetWithSearch(
          cotx: context,
          bottomSheetTitle: 'اختر الفئة...',
          hint: vm.selectedSubCategory?.name ?? 'اختر الفئة...',
          listOfItems: commonViewModel.subCategories,
          isLoading: commonViewModel.isLoadingSubCategories,
          onItemTap:
              (
                String? name,
                int? id, {
                int? indexOfSelectedItem,
                dynamic selectedItem,
              }) {
                Navigator.pop(context);
                vm.setSubCategory(context, id);
              },
        ),

        const SizedBox(height: 24),

        const Divider(color: Color(0xFFE1E8EF), thickness: 1),

        const SizedBox(height: 24),

        // --- 2. تفاصيل الإعلان ---
        _buildSectionTitle(context, 'تفاصيل الإعلان'),
        const SizedBox(height: 16),

        // عنوان الإعلان
        _buildLabel(context, 'عنوان الإعلان', isRequired: true),
        _buildTextField(
          controller: vm.titleController,
          hint: 'مثال: سيارة تويوتا كامري 2020',
        ),

        // السعر
        const SizedBox(height: 16),
        _buildLabel(context, 'السعر (اختياري)', isRequired: false),
        _buildTextField(
          controller: vm.priceController,
          hint: '0',
          suffixText: 'ر.ي',
          keyboardType: TextInputType.number,
        ),

        // حالة المنتج (جديد / مستعمل)
        const SizedBox(height: 16),
        _buildLabel(context, 'الحالة', isRequired: true),
        Row(
          children: [
            Expanded(
              child: _buildConditionBox(
                context: context,
                title: 'جديد',
                iconAssetString: IconAssets.newIconContainer,
                isSelected: vm.condition == 1,
                onTap: () => vm.setCondition(1),
                activeColor: const Color(0xFF21C55E),
                // أخضر حسب تصميم فيجما
                tagText: 'جديد',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConditionBox(
                context: context,
                title: 'مستعمل',
                iconAssetString: IconAssets.usedIconContainer,
                isSelected: vm.condition == 2,
                onTap: () => vm.setCondition(2),
                activeColor: const Color(0xFFF59E0A),
                // برتقالي حسب تصميم فيجما
                tagText: 'مستعمل',
              ),
            ),
          ],
        ),

        // الوصف
        const SizedBox(height: 16),
        _buildLabel(context, 'الوصف', isRequired: true),
        _buildTextField(
          controller: vm.descriptionController,
          hint: 'اكتب وصفاً تفصيلياً للإعلان يوضح المميزات والعيوب...',
          maxLines: 5,
          maxLength: 500,
        ),

        // المدينة
        const SizedBox(height: 16),
        _buildLabel(context, 'المدينة', isRequired: true),
        CustomBottomSheetWithSearch(
          cotx: context,
          bottomSheetTitle: 'اختر المدينة',
          hint: vm.selectedCity?.name ??  'اختر المدينة',
          listOfItems: commonViewModel.cities,
          onItemTap:
              (
                String? name,
                int? id, {
                int? indexOfSelectedItem,
                dynamic selectedItem,
              }) {
                Navigator.pop(context);
                vm.setCity(context, id);
              },
        ),
        const SizedBox(height: 10),

        CustomBottomSheetWithSearch(
          cotx: context,
          bottomSheetTitle: 'اختر المنطقة',
          hint: vm.selectedRegion?.name ?? 'اختر المنطقة',
          listOfItems: commonViewModel.regions,
          isLoading: commonViewModel.isLoadingRegion,
          onItemTap:
              (
                String? name,
                int? id, {
                int? indexOfSelectedItem,
                dynamic selectedItem,
              }) {
                Navigator.pop(context);
                vm.setRegion(context, id);
              },
        ),

        // --- 3. صندوق النصائح ---
        const SizedBox(height: 32),
        _buildTipsBox(),

        // مسافة سفلية
        const SizedBox(height: 20),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // ✅ Helper Widgets (للحفاظ على نظافة الكود وإعادة الاستخدام)
  // --------------------------------------------------------------------------

  Widget _buildSectionTitle(BuildContext context, String title) {
    return CustomText(
      title: title,
      size: Theme.of(context).textTheme.bodySmall!.fontSize!,
      fontWeight: FontWeight.w800,
      color: AppColors.current.blue,
    );
  }

  Widget _buildLabel(
    BuildContext context,
    String text, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          CustomText(
            title: text,
            size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F162A),
          ),
          if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        // محاذاة النص للعربية
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          color: Color(0xFF0F162A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFA9A9A9),
            fontSize: 13,
            fontFamily: 'Tajawal',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixText: suffixText,
          suffixStyle: const TextStyle(
            color: Color(0xFF63748A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
          counterText: maxLength != null
              ? null
              : "", // إخفاء العداد الافتراضي إذا أردت تصميم خاص
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: CustomText(
            title: hint,
            color: Color(0xFFA9A9A9),
            size: Theme.of(context).textTheme.bodySmall!.fontSize! - 3,
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF63748A),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: CustomText(
                title: item,
                color: Color(0xFF0F162A),
                size: Theme.of(context).textTheme.bodySmall!.fontSize! - 3,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdown2({
    required BuildContext cotx,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return CustomBottomSheetWithSearch(
      cotx: cotx,
      bottomSheetTitle: value ?? 'اختر من القائمة',
      hint: hint,
      listOfItems: items,
      onItemTap:
          (
            String? name,
            int? id, {
            int? indexOfSelectedItem,
            dynamic selectedItem,
          }) {
            onChanged(name);
          },
    );
  }

  Widget _buildConditionBox({
    required BuildContext context,
    required String title,
    required String iconAssetString,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required String tagText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 80, // ارتفاع مناسب
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE1E8EF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                CusSvgIcons(
                  iconAssetString: iconAssetString,
                  size: isTablet(context) ? 50 : 35,
                ),
                SizedBox(width: 10),
                Center(
                  child: CustomText(
                    title: title,
                    size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F162A),
                  ),
                ),
              ],
            ),
            // التاق الصغير الملون (دائرة صغيرة في الزاوية)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_outlined,
                color: Color(0xFF2462EB),
                size: 20,
              ),
              const SizedBox(width: 8),
              const CustomText(
                title: 'نصائح لكتابة الإعلان',
                size: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F162A),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('اكتب عنواناً واضحاً ومختصراً'),
          _buildTipItem('حدد السعر المناسب للمنتج'),
          _buildTipItem('اذكر كافة التفاصيل المهمة'),
          _buildTipItem('كن صادقاً في وصف الحالة'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF2462EB)),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              title: text,
              size: 13,
              color: const Color(0xFF63748A),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
