import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_button.dart';
import '../../../custom_widgets/custom_text.dart';
import 'categories_admin_vm.dart';

class CategoriesAdminScreen extends StatelessWidget {
  const CategoriesAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoriesAdminVM(),
      child: Consumer<CategoriesAdminVM>(
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
                    CustomText(title: 'إدارة الفئات', size: Theme.of(context).textTheme.bodySmall!.fontSize, fontWeight: FontWeight.bold),
                    SizedBox(
                      width: 180,
                      child: CustomButton(
                        text: 'إضافة فئة رئيسية',
                        btnTextSize: Theme.of(context).textTheme.bodySmall!.fontSize! - 4,
                        onTap: () {
                          vm.catNameController.clear();
                          vm.clearSelectedImage();
                          _showCategoryDialog(context, vm, null);
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
                      : vm.categories.isEmpty
                      ? Center(child: CustomText(title: 'لا توجد فئات حالياً', size: Theme.of(context).textTheme.bodySmall!.fontSize! - 3,))
                      : ListView.builder(
                    itemCount: vm.categories.length,
                    itemBuilder: (context, index) {
                      final category = vm.categories[index];
                      final isExpanded = vm.expandedCategories.contains(category.id);

                      // 👈 معالجة الرابط عبر الـ ViewModel ليكون آمناً وكاملاً
                      final finalImageUrl = vm.getFullImageUrl(category.imageUrl);
                      final hasImage = finalImageUrl.isNotEmpty;
                      debugPrint("Has image $hasImage ..Final image URL for category '${category.name}': $finalImageUrl");

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
                            // === 1. صف الفئة الرئيسية ===
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F7FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: hasImage
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    finalImageUrl,
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
                                    },
                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.category, color: Colors.blue),
                                  ),
                                )
                                    : const Icon(Icons.category, color: Colors.blue),
                              ),
                              title: CustomText(title: category.name, fontWeight: FontWeight.bold, size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    tooltip: 'تعديل',
                                    onPressed: () {
                                      vm.prepareCategoryForEdit(category);
                                      _showCategoryDialog(context, vm, category.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'حذف',
                                    onPressed: () => _confirmDeleteCategory(context, vm, category.id),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 30),
                                    onPressed: () => vm.toggleCategoryExpansion(category.id),
                                  ),
                                ],
                              ),
                            ),

                            // === 2. الفئات الفرعية ===
                            if (isExpanded) ...[
                              const Divider(height: 1),
                              Container(
                                color: const Color(0xFFFAFBFF),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSubCategoriesList(context, vm, category.id),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      width: 150,
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          vm.subCatNameController.clear();
                                          _showAddOrEditSubCategoryDialog(context, vm, category.id, null);
                                        },
                                        icon: const Icon(Icons.add, size: 18),
                                        label: CustomText(title: 'إضافة فرع', color: Colors.white, size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5),
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

  Widget _buildSubCategoriesList(BuildContext context, CategoriesAdminVM vm, int categoryId) {
    final subCats = vm.subCategoriesMap[categoryId];

    if (subCats == null) {
      return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
    }
    if (subCats.isEmpty) {
      return CustomText(title: 'لا توجد فروع حالياً، يمكنك الإضافة من الزر أدناه.',
          size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2, color: Colors.grey);
    }

    return Column(
      children: subCats.map((subCat) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.3))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(title: '—  ${subCat.name}', size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5, fontWeight: FontWeight.bold),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20),
                    onPressed: () {
                      vm.prepareSubCategoryForEdit(subCat);
                      _showAddOrEditSubCategoryDialog(context, vm, categoryId, subCat.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _confirmDeleteSubCategory(context, vm, categoryId, subCat.id),
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
  // الديالوجات
  // =========================================================

  void _showCategoryDialog(BuildContext context, CategoriesAdminVM vm, int? categoryId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final fontSize = Theme.of(context).textTheme.bodySmall!.fontSize!;

        return ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: CustomText(title: categoryId == null ? 'إضافة فئة رئيسية' : 'تعديل الفئة', size: fontSize + 2, fontWeight: FontWeight.bold),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                          controller: vm.catNameController,
                          style: TextStyle(fontSize: fontSize - 2),
                          decoration: InputDecoration(
                            labelText: 'اسم الفئة',
                            labelStyle: TextStyle(fontSize: fontSize - 2),
                            border: const OutlineInputBorder(),
                          )
                      ),
                      const SizedBox(height: 20),

                      CustomText(title: 'أيقونة الفئة (صورة)', fontWeight: FontWeight.bold, size: fontSize - 2),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => vm.pickImage(),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFC),
                            border: Border.all(color: Colors.grey.withOpacity(0.5), style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildImagePreview(vm, fontSize),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: CustomText(title: 'إلغاء', color: Colors.grey, size: fontSize - 2)
                  ),
                  ElevatedButton(
                    onPressed: () => vm.saveOrUpdateCategory(ctx, categoryId: categoryId),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.current.primary),
                    child: vm.isActionLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : CustomText(title: 'حفظ', color: Colors.white, size: fontSize - 2),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Widget _buildImagePreview(CategoriesAdminVM vm, double fontSize) {
    if (vm.webImageBytes != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(vm.webImageBytes!, fit: BoxFit.contain));
    } else if (vm.catIconUrl != null && vm.catIconUrl!.isNotEmpty) {

      // 👈 استخدام الدالة السحرية للحصول على الرابط الكامل داخل المعاينة أيضاً
      String finalUrl = vm.getFullImageUrl(vm.catIconUrl);

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
            finalUrl,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey)
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text("اضغط لاختيار صورة", style: TextStyle(color: Colors.grey, fontSize: fontSize - 4)),
        ],
      );
    }
  }

  void _showAddOrEditSubCategoryDialog(BuildContext context, CategoriesAdminVM vm, int parentId, int? subCatId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final fontSize = Theme.of(context).textTheme.bodySmall!.fontSize!;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: CustomText(title: subCatId == null ? 'إضافة فرع' : 'تعديل الفرع', size: fontSize + 2, fontWeight: FontWeight.bold),
          content: SizedBox(
            width: 400,
            child: TextField(
                controller: vm.subCatNameController,
                style: TextStyle(fontSize: fontSize - 2),
                decoration: InputDecoration(
                    labelText: 'اسم الفرع',
                    labelStyle: TextStyle(fontSize: fontSize - 2),
                    border: const OutlineInputBorder()
                )
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: CustomText(title: 'إلغاء', color: Colors.grey, size: fontSize - 2)
            ),
            ElevatedButton(
              onPressed: () => vm.saveOrUpdateSubCategory(ctx, parentId, subCatId: subCatId),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.current.primary),
              child: vm.isActionLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : CustomText(title: 'حفظ', color: Colors.white, size: fontSize - 2),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, CategoriesAdminVM vm, int categoryId) {
    showDialog(
        context: context,
        builder: (ctx) {
          final fontSize = Theme.of(context).textTheme.bodySmall!.fontSize!;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: CustomText(title: 'تأكيد الحذف', color: Colors.red, size: fontSize + 2, fontWeight: FontWeight.bold),
            content: CustomText(title: 'سيتم حذف الفئة نهائياً من السيرفر. هل أنت متأكد؟', size: fontSize - 2),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: CustomText(title: 'إلغاء', color: Colors.grey, size: fontSize - 2)
              ),
              ElevatedButton(
                onPressed: () { Navigator.pop(ctx); vm.deleteCategory(context, categoryId); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: CustomText(title: 'نعم، احذف', color: Colors.white, size: fontSize - 2),
              ),
            ],
          );
        }
    );
  }

  void _confirmDeleteSubCategory(BuildContext context, CategoriesAdminVM vm, int categoryId, int subCatId) {
    showDialog(
        context: context,
        builder: (ctx) {
          final fontSize = Theme.of(context).textTheme.bodySmall!.fontSize!;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: CustomText(title: 'تأكيد الحذف', color: Colors.red, size: fontSize + 2, fontWeight: FontWeight.bold),
            content: CustomText(title: 'سيتم حذف الفرع نهائياً من السيرفر. هل أنت متأكد؟', size: fontSize - 2),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: CustomText(title: 'إلغاء', color: Colors.grey, size: fontSize - 2)
              ),
              ElevatedButton(
                onPressed: () { Navigator.pop(ctx); vm.deleteSubCategory(context, categoryId, subCatId); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: CustomText(title: 'نعم، احذف', color: Colors.white, size: fontSize - 2),
              ),
            ],
          );
        }
    );
  }
}