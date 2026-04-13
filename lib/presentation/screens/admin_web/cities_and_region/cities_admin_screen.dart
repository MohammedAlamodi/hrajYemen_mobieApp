import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_button.dart';
import '../../../custom_widgets/custom_text.dart';
import 'cities_admin_vm.dart';

class CitiesAdminScreen extends StatelessWidget {
  const CitiesAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CitiesAdminVM(),
      child: Consumer<CitiesAdminVM>(
        builder: (context, vm, child) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(title: '', size: Theme.of(context).textTheme.bodySmall!.fontSize, fontWeight: FontWeight.bold),
                    SizedBox(
                      width: 180,
                      child: CustomButton(
                        text: 'إضافة مدينة',
                        btnTextSize: Theme.of(context).textTheme.bodySmall!.fontSize! - 4,
                        onTap: () {
                          vm.cityNameController.clear();
                          _showCityDialog(context, vm, null);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                Expanded(
                  child: vm.isLoading
                      ? Center(child: CircularProgressIndicator(color: AppColors.current.primary))
                      : vm.cities.isEmpty
                      ? Center(child: CustomText(title: 'لا توجد مدن حالياً', size: Theme.of(context).textTheme.bodySmall!.fontSize! - 3,))
                      : ListView.builder(
                    itemCount: vm.cities.length,
                    itemBuilder: (context, index) {
                      final city = vm.cities[index];
                      final isExpanded = vm.expandedCities.contains(city.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        elevation: 0,
                        child: Column(
                          children: [
                            // === 1. صف المدينة الرئيسية ===
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.location_city, color: Colors.blue), // أيقونة المدينة
                              ),
                              title: CustomText(title: city.name, fontWeight: FontWeight.bold, size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    tooltip: 'تعديل',
                                    onPressed: () {
                                      vm.prepareCityForEdit(city);
                                      _showCityDialog(context, vm, city.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'حذف',
                                    onPressed: () => _confirmDeleteCity(context, vm, city.id),
                                  ),
                                  const SizedBox(width: 10),
                                  // زر السهم الذي يفتح ويغلق
                                  IconButton(
                                    icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 30),
                                    onPressed: () => vm.toggleCityExpansion(city.id),
                                  ),
                                ],
                              ),
                            ),

                            // === 2. المناطق (تظهر فقط إذا كان isExpanded) ===
                            if (isExpanded) ...[
                              const Divider(height: 1),
                              Container(
                                color: const Color(0xFFFAFBFF),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildRegionsList(context, vm, city.id),
                                    const SizedBox(height: 15),

                                    // 👈 زر إضافة منطقة في آخر القائمة
                                    SizedBox(
                                      width: 150,
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          vm.regionNameController.clear();
                                          _showAddOrEditRegionDialog(context, vm, city.id, null);
                                        },
                                        icon: const Icon(Icons.add, size: 18),
                                        label: CustomText(title: 'إضافة منطقة', color: Colors.white, size:
                                        Theme.of(context).textTheme.bodySmall!.fontSize! - 5),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.current.primary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // بناء قائمة المناطق المنسدلة
  Widget _buildRegionsList(BuildContext context, CitiesAdminVM vm, int cityId) {
    final regions = vm.regionsMap[cityId];

    if (regions == null) {
      return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
    }
    if (regions.isEmpty) {
      return CustomText(title: 'لا توجد مناطق حالياً، يمكنك الإضافة من الزر أدناه.',
          size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
          color: Colors.grey);
    }

    return Column(
      children: regions.map((region) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(title: '—  ${region.name}',
                  size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5,
                  fontWeight: FontWeight.bold),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20),
                    onPressed: () {
                      vm.prepareRegionForEdit(region);
                      _showAddOrEditRegionDialog(context, vm, cityId, region.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => vm.deleteRegion(context, cityId, region.id),
                  ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  // =========================================================
  // الديالوجات الحقيقية (Dialogs)
  // =========================================================

  void _showCityDialog(BuildContext context, CitiesAdminVM vm, int? cityId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: CustomText(title: cityId == null ? 'إضافة مدينة' : 'تعديل المدينة', fontWeight: FontWeight.bold),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: vm.cityNameController,
                    decoration: const
                    InputDecoration(labelText: 'اسم المدينة',
                      border: OutlineInputBorder(),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const CustomText(title: 'إلغاء', color: Colors.grey)),
            ElevatedButton(
              onPressed: () => vm.saveOrUpdateCity(ctx, cityId: cityId),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.current.primary),
              child: vm.isActionLoading ? const CircularProgressIndicator(color: Colors.white) : const CustomText(title: 'حفظ', color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  void _showAddOrEditRegionDialog(BuildContext context, CitiesAdminVM vm, int cityId, int? regionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: CustomText(title: regionId == null ? 'إضافة منطقة' : 'تعديل المنطقة', fontWeight: FontWeight.bold),
          content: SizedBox(
            width: 400,
            child: TextField(controller: vm.regionNameController, decoration: const InputDecoration(labelText: 'اسم المنطقة', border: OutlineInputBorder())),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const CustomText(title: 'إلغاء')),
            ElevatedButton(
              onPressed: () => vm.saveOrUpdateRegion(ctx, cityId, regionId: regionId),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.current.primary),
              child: vm.isActionLoading ? const CircularProgressIndicator(color: Colors.white) : const CustomText(title: 'حفظ', color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCity(BuildContext context, CitiesAdminVM vm, int cityId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const CustomText(title: 'تأكيد الحذف', color: Colors.red, fontWeight: FontWeight.bold),
        content: const CustomText(title: 'سيتم حذف المدينة نهائياً من السيرفر بجميع مناطقها. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const CustomText(title: 'إلغاء')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); vm.deleteCity(context, cityId); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const CustomText(title: 'نعم، احذف', color: Colors.white),
          ),
        ],
      ),
    );
  }
}