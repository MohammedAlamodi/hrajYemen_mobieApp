import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';

import '../../../../model/category_model.dart';
import '../../categories/category_products_screen.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;

  const CategoryItem({Key? key, required this.category}) : super(key: key);


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
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CategoryProductsScreen(
              category: category,
            ))
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.current.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.transparent),
              ),
              child: buildCategoryIcon(category),
            ),
            const SizedBox(height: 8),
            CustomText(title:
              category.name,
                fontWeight: FontWeight.w500,
              size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
            ),
          ],
        ),
      ),
    );
  }
}