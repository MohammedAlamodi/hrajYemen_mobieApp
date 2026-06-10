import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_button.dart';
import '../../../custom_widgets/custom_text.dart';
import 'ads_admin_vm.dart';

class AdsAdminScreen extends StatelessWidget {
  final String? initialUserId;
  final String? initialStatus;

  const AdsAdminScreen({super.key, this.initialUserId, this.initialStatus});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdsAdminVM(
          initialUserId: initialUserId,
          initialStatus: initialStatus
      ),
      child: Consumer<AdsAdminVM>(
        builder: (context, vm, child) {
          final fontSize = Theme.of(context).textTheme.bodySmall!.fontSize!;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildFilterButton('الكل', null, vm, fontSize),
                          const SizedBox(width: 8),
                          _buildFilterButton('إعلانات نشطة', 'active', vm, fontSize),
                          const SizedBox(width: 8),
                          _buildFilterButton('إعلانات منتهية', 'expired', vm, fontSize),
                          const SizedBox(width: 8),
                          _buildFilterButton('إعلانات محظورة', 'blocked', vm, fontSize),

                          // شريحة توضح لو كنا نعرض إعلانات مستخدم معين
                          // if (vm.activeUserIdFilter != null) ...[
                          //   const Spacer(),
                          //   Chip(
                          //     label: const Text('إعلانات مستخدم مخصص', style: TextStyle(color: Colors.white)),
                          //     backgroundColor: AppColors.current.primary,
                          //     deleteIconColor: Colors.white,
                          //     onDeleted: () => vm.clearUserFilter(),
                          //   ),
                          // ]
                        ],
                      ),
                    ),
                    // شريط البحث وأزرار التحديث
                    Row(
                      children: [
                        SizedBox(
                          width: 250,
                          height: 40,
                          child: TextField(
                            controller: vm.searchIdController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'ابحث برقم الإعلان...',
                              hintStyle: TextStyle(fontSize: fontSize - 4),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  vm.clearSearch(); // مسح البحث وجلب الكل
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onSubmitted: (value) {
                              if(value.isNotEmpty) {
                                vm.searchByAdId(value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          tooltip: 'تحديث القائمة',
                          onPressed: () => vm.fetchInitialProducts(),
                        ),
                      ],
                    )
                  ],
                ),

                // const SizedBox(height: 16),

                // 🔥 أزرار الفلترة السريعة (النشطة، المنتهية، المحظورة)


                const SizedBox(height: 16),
                const Divider(),

                // عرض الإعلانات (الشبكة)
                Expanded(
                  child: vm.isLoading
                      ? Center(child: CircularProgressIndicator(color: AppColors.current.primary))
                      : vm.products.isEmpty
                      ? Center(child: CustomText(title: 'لا توجد إعلانات تطابق الفلتر', size: fontSize - 3))
                      : _buildAdsGrid(context, vm, fontSize),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔥 ودجت زر الفلترة (يتغير لونه إذا كان نشطاً)
  Widget _buildFilterButton(String title, String? statusValue, AdsAdminVM vm, double fontSize) {
    final isSelected = vm.activeStatusFilter == statusValue;
    return InkWell(
      onTap: () => vm.changeStatusFilter(statusValue),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.current.primary : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.current.primary : Colors.grey.shade300),
        ),
        child: CustomText(
          title: title,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          size: fontSize - 4,
        ),
      ),
    );
  }

  Widget _buildAdsGrid(BuildContext context, AdsAdminVM vm, double fontSize) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: vm.products.length,
            itemBuilder: (context, index) {
              final product = vm.products[index];

              bool isActive = product.isActive ?? true;

              bool isBlocked = product.isBlocked ?? false;

              String? coverImage;
              if (product.images.toString() != 'null' && product.images.isNotEmpty) {
                coverImage = vm.getFullImageUrl(product.images.first.imageUrl ?? '');
              }

              return InkWell(
                onTap: () => _showProductDetailsDialog(context, vm, product.id ?? 0, fontSize),
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          color: const Color(0xFFF4F7FE),
                          child: coverImage != null && coverImage.isNotEmpty
                              ? Image.network(coverImage, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey))
                              : const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomText(
                                title: product.title ?? 'بدون عنوان',
                                fontWeight: FontWeight.bold,
                                size: fontSize - 4,
                                maxLines: 1,
                              ),
                              CustomText(
                                title: '${product.price ?? 0} ريال',
                                color: AppColors.current.primary,
                                fontWeight: FontWeight.bold,
                                size: fontSize - 4,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(title: formatTimeAgo(product.createdAt) ?? '', size: fontSize - 6, color: Colors.grey),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isBlocked
                                          ? Colors.red.withOpacity(0.1)
                                          : (isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomText(
                                      // إذا محظور اكتب محظور، وإلا افحص هل هو نشط أم منتهي
                                      title: isBlocked ? 'محظور' : (isActive ? 'نشط' : 'منتهي'),
                                      color: isBlocked
                                          ? Colors.red
                                          : (isActive ? Colors.green : Colors.orange),
                                      size: fontSize - 6,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (vm.hasMoreData)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: 200,
              child: CustomButton(
                text: 'تحميل المزيد',
                loading: vm.isLoadingMore,
                onTap: () => vm.loadMoreProducts(),
                btnTextSize: fontSize - 4,
              ),
            ),
          ),
      ],
    );
  }

  void _showProductDetailsDialog(BuildContext context, AdsAdminVM vm, int productId, double fontSize) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final product = await vm.getProductDetails(productId);

    if (context.mounted) Navigator.pop(context);

    if (product == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر جلب تفاصيل الإعلان')));
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) {
          return ListenableBuilder(
              listenable: vm,
              builder: (context, _) {
                final isActive = product!.isActive ?? true;

                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: EdgeInsets.zero,
                  content: SizedBox(
                    width: 800,
                    height: 600,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: const BoxDecoration(color: Color(0xFFF4F7FE), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(title: 'تفاصيل الإعلان #${product.id}', fontWeight: FontWeight.bold, size: fontSize),
                              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText(title: product.title ?? '', fontWeight: FontWeight.bold, size: fontSize + 2),
                                        const SizedBox(height: 10),
                                        CustomText(title: '${product.price ?? 0} ريال', color: AppColors.current.primary, fontWeight: FontWeight.bold, size: fontSize),
                                        const SizedBox(height: 20),

                                        CustomText(title: 'الوصف:', color: Colors.grey, size: fontSize - 4),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(color: const Color(0xFFFAFBFF), borderRadius: BorderRadius.circular(8)),
                                          child: CustomText(title: product.description ?? 'لا يوجد وصف', size: fontSize - 2),
                                        ),
                                        const SizedBox(height: 20),

                                        _buildInfoRow('القسم:', product.categoryName ?? '', fontSize),
                                        _buildInfoRow('المدينة:', product.cityName ?? '', fontSize),
                                        _buildInfoRow('تاريخ النشر:', formatTimeAgo(product.createdAt) ?? '', fontSize),
                                        _buildInfoRow('المشاهدات:', '${product.viewsCount ?? 0} مشاهدة', fontSize),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),

                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 250,
                                        width: double.infinity,
                                        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
                                        clipBehavior: Clip.antiAlias,
                                        child: (product.images.toString() != 'null' && product.images.isNotEmpty)
                                            ? Image.network(vm.getFullImageUrl(product.images.first.imageUrl ?? ''), fit: BoxFit.cover)
                                            : const Icon(Icons.image, size: 80, color: Colors.grey),
                                      ),
                                      const Spacer(),

                                      SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton.icon(
                                            onPressed: vm.isActionLoading ? null : () => vm.blockOrUnblockAd(ctx, product.id ?? 0),
                                            icon: Icon(
                                                (product.isBlocked ?? false) ? Icons.check_circle : Icons.block,
                                                color: Colors.white
                                            ),
                                            label: vm.isActionLoading
                                                ? const CircularProgressIndicator(color: Colors.white)
                                                : CustomText(
                                              title: (product.isBlocked ?? false) ? 'إلغاء الحظر عن الإعلان' : 'حظر هذا الإعلان',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              size: fontSize - 2,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: (product.isBlocked ?? false) ? Colors.green : Colors.red,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          )
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
          );
        },
      );
    }
  }

  Widget _buildInfoRow(String title, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CustomText(title: title, color: Colors.grey, size: fontSize - 2),
          const SizedBox(width: 10),
          CustomText(title: value, fontWeight: FontWeight.bold, size: fontSize - 2),
        ],
      ),
    );
  }

  String formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return 'منذ ${diff.inMinutes} دقيقة';
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays <= 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

