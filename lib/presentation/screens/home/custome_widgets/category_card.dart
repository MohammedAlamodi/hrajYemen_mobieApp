import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import '../../../../model/category_model.dart';
import '../../../custom_widgets/custom_text.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });


  Widget buildCategoryIcon(CategoryModel category) {
    // إذا كانت الصورة موجودة في السيرفر
    if (category.imageUrl != null && category.imageUrl!.isNotEmpty) {
      return Image.network(
        category.imageUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(category.name), // إذا فشل تحميل الصورة
      );
    }
    // إذا كانت القيمة null من السيرفر، نعرض أيقونة افتراضية
    else {
      return _buildDefaultIcon(category.name);
    }
  }

  // دالة مساعدة لرسم أيقونة افتراضية بناءً على اسم القسم
  Widget _buildDefaultIcon(String name) {
    IconData icon;
    if (name.contains('سيارات')) {
      icon = Icons.directions_car;
    } else if (name.contains('عقارات')) {
      icon = Icons.home_work;
    }
    else if (name.contains('جوالات')) {
      icon = Icons.phone_android;
    }
    else{
      icon = Icons.category; // أيقونة عامة
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF2462EB)),
    );
  }


  @override
  Widget build(BuildContext context) {
    // final category = categories[index];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E8EF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // دائرة الأيقونة
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                // color: category.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                color: AppColors.current.primary.withOpacity(0.1),
              ),
              child: buildCategoryIcon(category),
            ),
            const SizedBox(height: 12),
            // العنوان
            CustomText(
              title: category.name,
              size: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F162A),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}