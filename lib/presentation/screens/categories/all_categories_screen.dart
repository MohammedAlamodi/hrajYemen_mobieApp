import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';
import '../../../configurations/localization/i18n.dart';
import '../../custom_widgets/Custom_header_bar.dart';
import '../../custom_widgets/custom_text.dart';
import '../../custom_widgets/loading_widgets.dart';
import '../home/custome_widgets/category_card.dart';
import 'all_categories_view_model.dart';
import 'category_products_screen.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AllCategoriesViewModel()..fetchCategories(),
      child: Scaffold(
        backgroundColor: Colors.white, // لون الخلفية من فيجما
        // backgroundColor: const Color(0xFFF8F9FB), // لون الخلفية من فيجما
        body: Consumer<AllCategoriesViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                CustomHeaderBar(
                  title: 'كل الأقسام',
                  showSearch: true,
                  onSearchChange: vm.searchCategories,
                ),

                const SizedBox(height: 16),

                // 3. شبكة الأقسام (Grid)
                Expanded(
                  child: vm.isLoading
                      ? Center(
                          child: CustomLoadingWidget(
                            text: S.of(context)!.loading,
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // عمودين
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio:
                                    1.2, // نسبة العرض للارتفاع للكارد
                              ),
                          itemCount: vm.categories.length,
                          itemBuilder: (context, index) {
                            final category = vm.categories[index];
                            return CategoryCard(
                              category: category,
                              onTap: () {
                                // الانتقال لصفحة منتجات هذا القسم
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryProductsScreen(
                                      category: category,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
