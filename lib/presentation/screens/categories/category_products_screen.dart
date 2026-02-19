import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/localization/i18n.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';
import '../../../../model/category_model.dart';
import '../../custom_widgets/Custom_header_bar.dart';
import '../home/custome_widgets/Product_list_viewer.dart';
import 'category_products_view_model.dart';

class CategoryProductsScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryProductsViewModel()..fetchProductsByCategory(category.id),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 1. الهيدر المخصص (مع زر الرجوع والبحث)
            // نستخدم الهيدر المخصص (قم بتعديله ليقبل زر رجوع إذا لم يكن يدعم ذلك، أو استخدم CustomHeaderBar من الكود السابق)
            CustomHeaderBar(
              title: category.name,
              showSearch: true,
              onSearchChange: (query) {

              },
            ),

            // 2. المحتوى (المنتجات)
            Expanded(
              child: Consumer<CategoryProductsViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading) {
                    return Center(child: CustomLoadingWidget(
                      text: S.of(context)!.loading,
                    ));
                  }

                  // 🔥 هنا نستخدم الويدجت الجاهز الذي بنيناه سابقاً
                  // هو يحتوي داخله على زر التبديل (Grid/List) تلقائياً
                  return ProductListViewer(
                    title: '', // اسم القسم (سيارات، عقارات...)
                    products: vm.products,
                    // يمكنك تفعيل البيجنيشن هنا أيضاً إذا أردت
                    onScrollEnd: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}