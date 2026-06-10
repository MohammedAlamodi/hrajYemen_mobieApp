import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/localization/i18n.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';
import 'package:ye_hraj/presentation/screens/customer/home/home_view_model.dart';
import '../../../../model/category_model.dart';
import '../../../custom_widgets/Custom_header_bar.dart';
import '../home/custome_widgets/Product_list_viewer.dart';
import 'category_products_view_model.dart';

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late CategoryProductsViewModel vm;
  late HomeViewModel homeViewModel;

  @override
  void initState() {
    super.initState();
    vm = Provider.of<CategoryProductsViewModel>(context, listen: false);
    homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    // جلب الأقسام الفرعية لهذا القسم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.initData(widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<CategoryProductsViewModel>(context);
    homeViewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. الهيدر المخصص (مع زر الرجوع والبحث)
          // نستخدم الهيدر المخصص (قم بتعديله ليقبل زر رجوع إذا لم يكن يدعم ذلك، أو استخدم CustomHeaderBar من الكود السابق)
          CustomHeaderBar(
            title: widget.category.name,
            showSearch: true,
            searchController: homeViewModel.sherTextCont,
            onSearchChange: (query) {
              homeViewModel.toggleCategory(widget.category.id);

              homeViewModel.onSearchTextChanged();
            },
          ),

          // 2. المحتوى (المنتجات)
          Expanded(
            child: Builder(
              builder: (context) {
                if (vm.isLoading) {
                  return Center(
                    child: CustomLoadingWidget(text: S.of(context)!.loading),
                  );
                }

                // 🔥 هنا نستخدم الويدجت الجاهز الذي بنيناه سابقاً
                // هو يحتوي داخله على زر التبديل (Grid/List) تلقائياً
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProductListViewer(
                    titleWidget: SubCategoriesHorizontalList(
                      categoryId: widget.category.id,
                    ),
                    products: vm.products,
                    isLoadingMore: vm.isLoadingMore,
                    onScrollEnd: () {
                      vm.loadMoreProducts();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubCategoriesHorizontalList extends StatelessWidget {
  final int categoryId;

  const SubCategoriesHorizontalList({Key? key, required this.categoryId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استدعاء الـ ViewModel الخاص بك
    final vm = Provider.of<CategoryProductsViewModel>(context);

    if (vm.subCategories.isEmpty) {
      return const SizedBox.shrink(); // إخفاء الويدجت تماماً
    }

    // عرض القائمة الأفقية
    return SizedBox(
      height: 40, // ارتفاع مناسب للأزرار (Chips)
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // مسافة من حواف الشاشة
        itemCount: vm.subCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        // مسافة بين كل مربع
        itemBuilder: (context, index) {
          final subCat = vm.subCategories[index];
          final isSelected = vm.selectedSubCategoryId == subCat.id;

          return GestureDetector(
            onTap: () {
              // عند الضغط، نحدد القسم ونفلتر المنتجات
              vm.selectSubCategory(
                categoryId: categoryId,
                subCategoryId: subCat.id,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // لون الخلفية يتغير إذا كان محدداً
                color: isSelected ? AppColors.current.primary200 : Colors.white,
                borderRadius: BorderRadius.circular(
                    isSelected ? 20 : 15
                ),
                // أو 20 لشكل بيضاوي (Pill)
                border: Border.all(
                  // لون الحدود يتغير إذا كان محدداً
                  color: isSelected
                      ? AppColors.current.primary
                      : const Color(0xFFE1E8EF),
                  width: 1.5,
                ),
              ),
              child: CustomText(title:
                subCat.name,
                  size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  // لون النص أبيض إذا كان محدداً، وإلا لون غامق
                  color: isSelected ? Colors.white : const Color(0xFF0F162A),
              ),
            ),
          );
        },
      ),
    );
  }
}
