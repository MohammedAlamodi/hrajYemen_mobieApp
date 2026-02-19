import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/localization/i18n.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';
import '../../custom_widgets/custom_text.dart';
import '../../custom_widgets/Custom_header_bar.dart';
import 'custom_widgets/my_ad_card.dart';
import 'edit_my_ad_screen.dart';
import 'my_ad_view_model.dart';

class MyAdsScreen extends StatefulWidget {
  final int curIndex;

  const MyAdsScreen({super.key, required this.curIndex});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  late MyAdViewModel vm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _init();
    });
  }

  Future<void> _init() async {
    vm = Provider.of<MyAdViewModel>(context, listen: false);
    await vm.fetchMyAds();
  }

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<MyAdViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.current.appBackground, // لون الخلفية من فيجما
      body: Column(
        children: [
          // 1. الهيدر
          const CustomHeaderBar(
            title: 'إعلاناتي',
            showBack: true,
            showSearch: false, // لا نحتاج بحث هنا حسب التصميم
            onSearchChange: null,
          ),

          // 2. التبويبات (Active / Expired)
          _buildTabs(vm),

          // القائمة
          Expanded(
            child: vm.isLoading
                ? Center(
                    child: CustomLoadingWidget(text: S.of(context)!.loading),
                  ) // أو CustomLoadingWidget
                : vm.currentAds.isEmpty
                ? _buildEmptyState()
                : _buildAdsList(context, vm),
          ),
        ],
      ),
    );
  }

  // بناء القائمة
  Widget _buildAdsList(BuildContext context, MyAdViewModel vm) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.currentAds.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final product = vm.currentAds[index];
        final bool isSold = product.status == AdStatus.sold.toString();

        return MyAdCard(
          title: product.title,
          price: product.price ?? 0.0,
          date: vm.formatDate(product.createdAt),
          views: product.viewsCount,
          // استخدام الصورة الأولى أو صورة افتراضية
          imageUrl: product.images.isNotEmpty
              ? product.images.first.imageUrl
              : "https://placehold.co/100x100",

          status: isSold ? AdStatus.sold : AdStatus.active,

          // الانتقال للتعديل
          onEditTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // ✅ نمرر المنتج الحقيقي هنا
                builder: (_) => EditAdScreen(product: product),
              ),
            ).then((_) {
              // عند العودة من التعديل، نحدث القائمة
              vm.fetchMyAds();
            });
          },
        );
      },
    );
  }

  Widget _buildTabs(MyAdViewModel vm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: Row(
        children: [
          // عكسنا الترتيب ليناسب اتجاه العربي (منتهية يسار - نشطة يمين) أو حسب الرغبة
          _buildTabItem(vm, title: 'نشطة', index: 0),
          _buildTabItem(vm, title: 'منتهية', index: 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    MyAdViewModel vm, {
    required String title,
    required int index,
  }) {
    final isSelected = vm.selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.changeTab(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2462EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomText(
              title: title,
              size: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF63748A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const CustomText(
            title: 'لا توجد إعلانات في هذه القائمة',
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
