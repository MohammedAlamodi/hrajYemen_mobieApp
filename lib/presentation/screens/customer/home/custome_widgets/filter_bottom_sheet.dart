// filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/model/cities_model.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';
import 'package:ye_hraj/presentation/screens/customer/home/home_view_model.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  // دالة مساعدة لفتح النافذة السفلية بسهولة من أي مكان
  static Future<CitiesModel?> show(BuildContext context, HomeViewModel vm) {

    return showModalBottomSheet<CitiesModel>(
      context: context,
      isScrollControlled: true, // لتجنب مشكلة الكيبورد
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context);

    // للحماية من مشكلة الكيبورد الذي يغطي الحقول
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان النافذة وزر الإلغاء
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               CustomText(title: 'تصفية النتائج', size: Theme.of(context).textTheme.bodySmall!.fontSize, fontWeight: FontWeight.bold),
              TextButton(
                onPressed: vm.clearFilters,
                child:  CustomText(title: 'إلغاء الفلتر',
                    size: Theme.of(context).textTheme.bodySmall!.fontSize,
                    color: Colors.red),
              ),
            ],
          ),
          const Divider(),

          // قسم المدن
          CustomText(title: 'اختر المدينة:', fontWeight: FontWeight.bold,
            size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,),
          const SizedBox(height: 8),
          _buildCitiesSection(context,vm),

          const SizedBox(height: 16),

          // قسم السعر
          CustomText(title: 'نطاق السعر:', fontWeight: FontWeight.bold,size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: vm.minPriceController,
                  type: TextInputType.number,
                    hint: 'أقل سعر',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: vm.maxPriceController,
                  type: TextInputType.number,
                    hint: 'أعلى سعر',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // زر التطبيق
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                vm.onSearchTextChanged(context: context);
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.current.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: CustomText(title: 'تطبيق',
                  size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,
                  color: Colors.white)),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCitiesSection(BuildContext context, HomeViewModel vm) {
    if (vm.isLoadingCities) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return Text(vm.errorMessage!, style: const TextStyle(color: Colors.red));
    }
    if (vm.cities.isEmpty) {
      return const Text('لا توجد مدن متاحة');
    }

    // عرض المدن كأزرار (Chips)
    return Wrap(
      spacing: 8,
      children: vm.cities.map((city) {
        final isSelected = vm.selectedCity?.id == city.id;
        return FilterChip(
          label: CustomText(title: city.name,
            size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,
          ),
          selected: isSelected,
          onSelected: (_) => vm.selectCity(city),
          selectedColor: Colors.blue.withOpacity(0.2),
          checkmarkColor: Colors.blue,
        );
      }).toList(),
    );
  }
}