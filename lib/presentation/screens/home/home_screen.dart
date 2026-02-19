import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/cust_svg_icons.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_button.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';

import '../../../configurations/resources/assets_manager.dart';
import '../../../model/category_model.dart';
import '../categories/all_categories_screen.dart';
import 'custome_widgets/Product_list_viewer.dart';
import 'custome_widgets/category_item.dart';
import 'custome_widgets/home_custom_app_bar.dart';

import 'package:provider/provider.dart';
import 'home_view_model.dart'; // استدعاء الـ VM

// ... Imports الأخرى (Widgets, Models, etc.)

class HomeScreen extends StatefulWidget {
  static const String routeName = "HomeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    // جلب البيانات الأولية عند بدء الصفحة
    Future.microtask(() =>
        Provider.of<HomeViewModel>(context, listen: false).getInitialData()
    );
  }

  // دوال الـ Scale والـ Tablet القديمة كما هي
  double _uiScale(BuildContext context) { /* ... نفس الكود السابق ... */ return 1.0; }
  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer للاستماع للتغييرات في الـ VM
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        final s = _uiScale(context);

        // حسابات الـ Responsive (نفس الكود السابق)
        final categoriesListHeight = (100.0 * s).clamp(92.0, 130.0);
        final categoriesExtent = (categoriesListHeight + (56.0 * s)).clamp(140.0, 190.0);
        final bannerIconSize = (110.0 * s).clamp(90.0, 150.0);
        final bannerExtent = (_isTablet(context) ? 190.0 : 175.0) * s;

        return Scaffold(
          backgroundColor: AppColors.current.appBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HomeCustomAppBar(),

                Expanded(
                  // إذا كان تحميل أولي نعرض Loading
                  child: vm.isLoading
                      ? const Center(child: CustomLoadingWidget(
                    text: 'جاري تحميل البيانات...',
                  ))
                      : NestedScrollView(
                    physics: const ClampingScrollPhysics(),
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [

                      // نفس الـ Headers السابقة تماماً
                      SliverPersistentHeader(
                        pinned: false,
                        delegate: FadeSlideSliverHeaderDelegate(
                          maxExtentHeight: categoriesExtent,
                          collapseDistanceFactor: 1.25,
                          child: ResponsiveCenter(
                            child: _CategoriesSection(
                              categories: vm.categories,
                              listHeight: categoriesListHeight,
                              scale: s,
                            ),
                          ),
                        ),
                      ),

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
                    ],

                    // تمرير بيانات الـ VM للـ Viewer
                    body: ResponsiveCenter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ProductListViewer(
                          title: 'الإعلانات',
                          products: vm.products, // البيانات من الـ VM
                          isLoadingMore: vm.isLoadingMore, // حالة تحميل المزيد
                          onScrollEnd: () {
                            // عند الوصول للنهاية، اطلب المزيد
                            vm.loadMoreProducts();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ----------------------------------------------------
/// ✅ ResponsiveCenter: يوسّط المحتوى ويحدد maxWidth
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
/// ✅ Animated Header Delegate (Fix overflow + scale down)
///  - Fade + Slide
///  - FittedBox(scaleDown) => يمنع RenderFlex overflow
///  - ويخلّي أيقونة البنر تصغر مع الانكماش
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
              // ✅ يحل overflow + يخلي المحتوى يصغر بشكل Layout حقيقي
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: maxExtentHeight, // design height
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
/// Categories Section (Responsive)
/// ------------------------------
class _CategoriesSection extends StatelessWidget {
  final List<CategoryModel> categories;
  final double listHeight;
  final double scale;

  const _CategoriesSection({
    required this.categories,
    required this.listHeight,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = (Theme.of(context).textTheme.bodySmall?.fontSize ?? 14) - 2;

    return Column(
      children: [
        Padding(
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
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AllCategoriesScreen())
                  );
                },
                child: CustomText(
                  title: 'عرض الكل',
                  size: titleSize,
                  color: AppColors.current.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemBuilder: (context, index) => CategoryItem(category: categories[index]),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------
/// Promo Banner (Responsive + Safe)
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
          // ✅ النصوص مرنة
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

          // ✅ الأيقونة Responsive ولا تسبب overflow
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
