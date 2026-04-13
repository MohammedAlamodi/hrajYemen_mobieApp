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
    Future.microtask(() => vm.getInitialData());
  }

  double _uiScale(BuildContext context) { return 1.0; }
  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<HomeViewModel>(context);
    final s = _uiScale(context);

    // حساب الارتفاعات للأقسام
    final categoriesListHeight = (100.0 * s).clamp(92.0, 130.0);
    final categoriesExtent = (categoriesListHeight + (56.0 * s)).clamp(140.0, 190.0);
    final bannerIconSize = (110.0 * s).clamp(90.0, 150.0);
    final bannerExtent = (_isTablet(context) ? 190.0 : 175.0) * s;

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
              physics: const ClampingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                List<Widget> slivers = [];

                // 1. قسم الأقسام الرئيسية (🔥 ثابت ويصغر بنعومة)
                slivers.add(
                  SliverPersistentHeader(
                    pinned: true, // 👈 السر هنا: يجعل الأقسام تثبت ولا تختفي
                    delegate: CategoriesPinnedHeaderDelegate(
                      vm: vm,
                      maxExtentHeight: categoriesExtent,
                      minExtentHeight: categoriesListHeight, // الارتفاع الأدنى بعد التصغير
                      scale: s,
                    ),
                  ),
                );

                // 2. البنر أو الأقسام الفرعية
                if (vm.selectedCategoryId != null) {
                  slivers.add(
                    SliverToBoxAdapter(
                      child: ResponsiveCenter(
                        child: _SubCategoriesSection(vm: vm),
                      ),
                    ),
                  );
                } else {
                  if (vm.sherTextCont.text.isEmpty) {
                    slivers.add(
                      SliverPersistentHeader(
                        pinned: false,
                        delegate: FadeSlideSliverHeaderDelegate(
                          maxExtentHeight: bannerExtent,
                          collapseDistanceFactor: 1.25,
                          child: ResponsiveCenter(
                            child: _PromoBanner(iconSize: bannerIconSize, scale: s),
                          ),
                        ),
                      ),
                    );
                  }
                }

                return slivers;
              },
              body: vm.isProductLoading
                  ? const Center(child: CustomLoadingWidget(text: 'جاري تحميل البيانات...'))
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
                      : Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        CustomText(
                          title: 'لا توجد إعلانات في هذا القسم حالياً',
                          color: AppColors.current.blackGrey,
                          size: 16,
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          onPressed: () async => await vm.getInitialData(),
                          icon: Icon(Icons.refresh, color: AppColors.current.primary),
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
    // حساب نسبة التمرير (من 0.0 إلى 1.0)
    final progress = (shrinkOffset / (maxExtentHeight - minExtentHeight)).clamp(0.0, 1.0);

    // حساب نسبة التصغير (عندما يثبت يصغر بنسبة 15%)
    final scaleFactor = 1.0 - (0.2 * progress);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.appBackground,
        // إضافة ظل خفيف جداً من الأسفل عندما يثبت القسم
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
              // 1. صف العنوان (يرتفع للأعلى ويختفي أثناء السكرول)
              Positioned(
                top: -shrinkOffset,
                left: 0,
                right: 0,
                height: maxExtentHeight - minExtentHeight,
                child: Opacity(
                  opacity: 1.0 - progress, // يتلاشى تدريجياً
                  child: _buildTitleRow(context),
                ),
              ),

              // 2. قائمة الأقسام (ثابتة في الأسفل وتصغر تدريجياً)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: minExtentHeight,
                child: Transform.scale(
                  scale: scaleFactor,
                  alignment: Alignment.bottomCenter, // يصغر من الأسفل للأعلى
                  child: _buildCategoriesList(),
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

  Widget _buildCategoriesList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: vm.categories.length,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      itemBuilder: (context, index) {
        final category = vm.categories[index];
        final isSelected = vm.selectedCategoryId == category.id;

        return CategoryItem(
          category: category,
          isSelected: isSelected,
          onTap: () => vm.toggleCategory(category.id),
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant CategoriesPinnedHeaderDelegate oldDelegate) {
    return vm != oldDelegate.vm ||
        maxExtentHeight != oldDelegate.maxExtentHeight ||
        minExtentHeight != oldDelegate.minExtentHeight;
  }
}

/// ----------------------------------------------------
/// ✅ ResponsiveCenter (كما هي)
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

/// ----------------------------------------------------
/// ✅ FadeSlideSliverHeaderDelegate (كما هي)
/// ----------------------------------------------------
class FadeSlideSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxExtentHeight;
  final double collapseDistanceFactor;
  final Widget child;

  FadeSlideSliverHeaderDelegate({
    required this.maxExtentHeight,
    required this.child,
    this.collapseDistanceFactor = 1.0,
  });

  @override
  double get maxExtent => maxExtentHeight;

  @override
  double get minExtent => 0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final collapseDistance = maxExtent * collapseDistanceFactor;
    final raw = 1 - (shrinkOffset / collapseDistance);
    final t = raw.clamp(0.0, 1.0);
    final eased = Curves.easeInOutCubic.transform(t);
    final translateY = lerpDouble(-22, 0, eased)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: Opacity(
            opacity: eased,
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: maxExtentHeight,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant FadeSlideSliverHeaderDelegate oldDelegate) {
    return oldDelegate.maxExtentHeight != maxExtentHeight ||
        oldDelegate.collapseDistanceFactor != collapseDistanceFactor ||
        oldDelegate.child != child;
  }
}

/// ------------------------------
/// الأقسام الفرعية (كما هي)
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

/// ------------------------------
/// البنر الترويجي (كما هو)
/// ------------------------------
class _PromoBanner extends StatelessWidget {
  final double iconSize;
  final double scale;

  const _PromoBanner({
    required this.iconSize,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final smallSize = (Theme.of(context).textTheme.bodySmall?.fontSize ?? 14) - 2;
    final pad = (14.0 * scale).clamp(12.0, 20.0);
    final gap = (12.0 * scale).clamp(10.0, 16.0);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.8, 0.2),
          end: const Alignment(0.1, 2.5),
          colors: [AppColors.current.primary, AppColors.current.primary50],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  title: 'بيع منتجك اليوم!',
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                const SizedBox(height: 4),
                CustomText(
                  title: 'آلاف المشترين بانتظارك',
                  color: const Color(0xFFCCFAF0),
                  size: smallSize,
                ),
                SizedBox(height: gap),
                Row(
                  children: [
                    CustomButton(
                      onTap: () {},
                      text: 'أضف إعلان مجاناً',
                      btnTextSize: smallSize,
                      btnTextColor: Colors.white,
                      btnColor: const Color(0xFF2462EB),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: (12 * scale).clamp(10.0, 16.0)),
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: FittedBox(
              fit: BoxFit.contain,
              child: CusSvgIcons(
                iconAssetString: IconAssets.frame_persons,
                size: iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}