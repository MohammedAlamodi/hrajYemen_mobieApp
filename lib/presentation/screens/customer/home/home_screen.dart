import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/helpers_functions.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/cust_svg_icons.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_button.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';

import '../../../../configurations/resources/assets_manager.dart';
import '../categories/all_categories_screen.dart';
import '../products/add_products/add_ad_screen.dart';
import 'custome_widgets/Product_list_viewer.dart';
import 'custome_widgets/category_item.dart';
import 'custome_widgets/home_custom_app_bar.dart';

import 'package:provider/provider.dart';
import 'home_view_model.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "HomeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = Provider.of<HomeViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.getInitialData();
    });
  }

  double _uiScale(BuildContext context) { return 1.0; }
  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<HomeViewModel>(context);
    final s = _uiScale(context);

    final categoriesListHeight = (100.0 * s).clamp(92.0, 130.0);
    final categoriesExtent = (categoriesListHeight + (56.0 * s)).clamp(140.0, 190.0);

    return Scaffold(
      backgroundColor: AppColors.current.appBackground,
      body: Column(
        children: [
          SizedBox(height: heightOfScreen(context) * 0.03,),
          HomeCustomAppBar(),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CustomLoadingWidget(text: 'جاري تحميل البيانات...'))
                : NestedScrollView(
              // ✅ الكلمة الصحيحة هي floatHeaderSlivers
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                List<Widget> slivers = [];

                // 1. قسم الأقسام الرئيسية (عائم: يختفي عند السحب للأسفل ويظهر عند السحب للأعلى)
                slivers.add(
                  SliverPersistentHeader(
                    pinned: false,
                    floating: true,
                    delegate: CategoriesPinnedHeaderDelegate(
                      vm: vm,
                      maxExtentHeight: categoriesExtent,
                      minExtentHeight: categoriesListHeight,
                      scale: s,
                    ),
                  ),
                );

                // 2. الأقسام الفرعية (تختفي للأسفل وتظهر عند السحب للأعلى)
                if (vm.selectedCategoryId != null) {
                  slivers.add(
                    SliverPersistentHeader(
                      pinned: false,
                      floating: true, // السلوك المطلوب: عائم
                      delegate: SubCategoriesPinnedHeaderDelegate(
                        vm: vm,
                        height: 60.0,
                      ),
                    ),
                  );
                }

                return slivers;
              },
              // 3. وضعنا الـ RefreshIndicator حول الـ body مباشرة لكي يعمل بشكل صحيح
              body: RefreshIndicator(
                color: AppColors.current.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await vm.getInitialData();
                },
                child: vm.isProductLoading
                    ? ListView(
                  // حولنا التحميل لـ ListView قابلة للسحب لكي تعمل علامة التحديث حتى اثناء التحميل
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 100),
                  children: const [
                    Center(child: CustomLoadingWidget(text: 'جاري تحميل البيانات...')),
                  ],
                )
                    : ResponsiveCenter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: vm.products.isNotEmpty
                        ? ProductListViewer(
                      titleWidget: CustomText(title: 'الإعلانات'),
                      products: vm.products,
                      isLoadingMore: vm.isLoadingMore,
                      onScrollEnd: () => vm.loadMoreProducts(),
                    )
                        : ListView(
                      // حولنا الحالة الفارغة لـ ListView قابلة للسحب لكي يقدر المستخدم يسحب للتحديث
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 100),
                      children: [
                        Center(
                          child: CustomText(
                            title: 'لا توجد إعلانات في هذا القسم حالياً',
                            color: AppColors.current.blackGrey,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: IconButton(
                            onPressed: () async => await vm.getInitialData(),
                            icon: Icon(Icons.refresh, color: AppColors.current.primary, size: 30,),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------
/// ✅ Delegate الخاص بالأقسام (يثبت ويصغر حجمه)
/// ----------------------------------------------------
class CategoriesPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final HomeViewModel vm;
  final double maxExtentHeight;
  final double minExtentHeight;
  final double scale;

  CategoriesPinnedHeaderDelegate({
    required this.vm,
    required this.maxExtentHeight,
    required this.minExtentHeight,
    required this.scale,
  });

  @override
  double get maxExtent => maxExtentHeight;

  @override
  double get minExtent => minExtentHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtentHeight - minExtentHeight)).clamp(0.0, 1.0);
    final scaleFactor = 1.0 - (0.2 * progress);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.appBackground,
        boxShadow: progress > 0.8
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ]
            : [],
      ),
      child: ResponsiveCenter(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                top: -shrinkOffset,
                left: 0,
                right: 0,
                height: maxExtentHeight - minExtentHeight,
                child: Opacity(
                  opacity: 1.0 - progress,
                  child: _buildTitleRow(context),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: minExtentHeight,
                child: Transform.scale(
                  scale: scaleFactor,
                  alignment: Alignment.bottomCenter,
                  child: _buildCategoriesList(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final titleSize = (Theme.of(context).textTheme.bodySmall?.fontSize ?? 14) - 2;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: (8 * scale).clamp(6.0, 12.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            title: 'الأقسام الرئيسية',
            fontWeight: FontWeight.w800,
            size: titleSize,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AllCategoriesScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomText(
                title: 'عرض الكل',
                size: titleSize,
                fontWeight: FontWeight.bold,
                color: AppColors.current.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context) {
    HomeViewModel homeViewModel = Provider.of<HomeViewModel>(context);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: homeViewModel.categories.length,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      itemBuilder: (context, index) {
        final category = homeViewModel.categories[index];

        return CategoryItem(
          category: category,
          isSelected: homeViewModel.selectedCategoryId == category.id,
          onTap: () => homeViewModel.toggleCategory(category.id),
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant CategoriesPinnedHeaderDelegate oldDelegate) {
    return true;
  }
}

/// ----------------------------------------------------
/// ✅ ResponsiveCenter
/// ----------------------------------------------------
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final maxWidth = w >= 1200
        ? 1100.0
        : w >= 900
        ? 900.0
        : w >= 600
        ? 600.0
        : double.infinity;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// ------------------------------
/// الأقسام الفرعية
/// ------------------------------
class _SubCategoriesSection extends StatelessWidget {
  final HomeViewModel vm;

  const _SubCategoriesSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingSubCategories) {
      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.2, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(left: 8, bottom: 10),
                  decoration: BoxDecoration(
                    color: Color.lerp(Colors.grey[200], Colors.grey[400], value),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
              onEnd: () {},
            );
          },
        ),
      );
    }

    if (vm.subCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: CustomText(
          title: 'لا توجد أقسام فرعية لهذا القسم',
          color: Colors.grey,
          size: 13,
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vm.subCategories.length,
        padding: const EdgeInsets.only(bottom: 10),
        itemBuilder: (context, index) {
          final subCat = vm.subCategories[index];
          final isSelected = vm.selectedSubCategoryId == subCat.id;

          return GestureDetector(
            onTap: () => vm.toggleSubCategory(subCat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.current.primary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.current.primary : const Color(0xFFE1E8EF),
                ),
              ),
              child: CustomText(
                title: subCat.name,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xFF0F162A),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ----------------------------------------------------
/// ✅ Delegate الخاص بالأقسام الفرعية
/// ----------------------------------------------------
class SubCategoriesPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final HomeViewModel vm;
  final double height;

  SubCategoriesPinnedHeaderDelegate({required this.vm, required this.height});

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.current.appBackground,
      alignment: Alignment.center,
      child: ResponsiveCenter(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: _SubCategoriesSection(vm: vm),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SubCategoriesPinnedHeaderDelegate oldDelegate) {
    return true;
  }
}