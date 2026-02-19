import 'package:flutter/material.dart';
import '../../../../model/category_model.dart';
import '../../../custom_widgets/custom_text.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                color: category.color.withOpacity(0.1),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 30,
              ),
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