import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/localization/i18n.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_button.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';
import 'package:ye_hraj/presentation/screens/customer/products/add_products/add_ad_view_model.dart';
import '../../../../model/product_model.dart';
import '../../../custom_widgets/Custom_header_bar.dart';
import '../../../custom_widgets/custom_text.dart';
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
        final bool isSold = !product.isActive;

        return MyAdCard(
          title: product.title,
          price: product.price ?? 0.0,
          priceCurrency: product.priceCurrency ?? 'RY',
          date: formatTimeAgo(product.updateAt),
          views: product.viewsCount,
          isBlocked: product.isBlocked,
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
          onDeleteTap: () {
            // إظهار ديلوج التأكيد
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const CustomText(
                    title: 'حذف الإعلان',
                    fontWeight: FontWeight.bold,
                  ),
                  content: const CustomText(
                    title: 'هل أنت متأكد من رغبتك في حذف هذا الإعلان؟',
                  ),
                  actions: [
                    SizedBox(),
                    Row(
                      children: [
                        CustomButton(
                          loading: vm.isDeletingLoading,
                          btnColor: Colors.redAccent,
                          onTap: () async {
                            await vm.deleteAd(
                              context,
                              product.id,
                            ); // استدعاء دالة الحذف
                          },
                          text: 'نعم متأكد',
                          btnTextColor: Colors.white,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const CustomText(
                            title: 'إلغاء',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
          onToggleStatusTap: () {
            // إظهار ديلوج التأكيد
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const CustomText(
                    title: 'تغيير حالة الإعلان',
                    fontWeight: FontWeight.bold,
                  ),
                  content: const CustomText(
                    title:
                        'هل أنت متأكد من رغبتك في تحويل حالة الإعلان إلى "مباع/منتهي"؟',
                  ),
                  actions: [
                    SizedBox(),
                    Row(
                      children: [
                        CustomButton(
                          // style: ElevatedButton.styleFrom(
                          //   backgroundColor: AppColors.current.primary,
                          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          // ),
                          loading: vm.isEditingLoading,
                          onTap: () async {
                            await vm.toggleAdStatus(
                              context,
                              product.id,
                            ); // استدعاء دالة التغيير
                          },
                          text: 'نعم متأكد',
                          btnTextColor: Colors.white,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const CustomText(
                            title: 'إلغاء',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
          onRefTap: () async {
            AddAdViewModel addAdVM = Provider.of<AddAdViewModel>(
              context,
              listen: false,
            );

            bool canUpdate = addAdVM.canEditProduct(
              context,
              product.updateAt,
            ); // نمرر المنتج للتعديل
            if (canUpdate) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const CustomText(title: 'تجديد الإعلان', fontWeight: FontWeight.bold),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(title: 'هل أنت متأكد من رغبتك في تجديد الإعلان؟', size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,),
                        SizedBox(height: 3,),
                        CustomText(title: 'في المره القادمه ستتمكن من تحديثه بعد مرور ٢٤ ساعه.', size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,),
                      ],
                    ),

                    actions: [
                      SizedBox(),
                      Row(
                        children: [
                          CustomButton(
                            loading: addAdVM.isLoadingPostAd,
                            onTap: () async {
                              MyAdViewModel myAdVM = Provider.of<MyAdViewModel>(
                                context,
                                listen: false,
                              );

                              myAdVM.originalProduct = product;

                              await myAdVM.editUpdateAtFun(context);

                              if(context.mounted){
                                Navigator.pop(context);
                              }
                            },
                            text: 'نعم متأكد',
                            btnTextColor: Colors.white,
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const CustomText(title: 'إلغاء', color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }
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
            color: isSelected ? AppColors.current.primary : Colors.transparent,
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
