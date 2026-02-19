import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';

import '../../../../model/category_model.dart';
import '../../categories/category_products_screen.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;

  const CategoryItem({Key? key, required this.category}) : super(key: key);

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
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.transparent),
              ),
              child: Icon(category.icon, color: category.color),
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