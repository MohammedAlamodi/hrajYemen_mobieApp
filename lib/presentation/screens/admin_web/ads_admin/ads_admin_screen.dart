import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_button.dart';
import '../../../custom_widgets/custom_text.dart';
import 'ads_admin_vm.dart';

class AdsAdminScreen extends StatelessWidget {
  const AdsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdsAdminVM(),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(title: 'إدارة الإعلانات', size: fontSize, fontWeight: FontWeight.bold),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      tooltip: 'تحديث القائمة',
                      onPressed: () => vm.fetchInitialProducts(),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                Expanded(
                  child: vm.isLoading
                      ? Center(child: CircularProgressIndicator(color: AppColors.current.primary))
                      : vm.products.isEmpty
                      ? Center(child: CustomText(title: 'لا توجد إعلانات حالياً', size: fontSize - 3))
                      : _buildAdsGrid(context, vm, fontSize),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // شبكة الإعلانات (Grid View) متجاوبة مع الويب
  Widget _buildAdsGrid(BuildContext context, AdsAdminVM vm, double fontSize) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300, // أقصى عرض للبطاقة (تتجاوب مع الشاشة)
              childAspectRatio: 0.8,   // نسبة الطول للعرض
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: vm.products.length,
            itemBuilder: (context, index) {
              final product = vm.products[index];
              final isActive = product.isActive ?? true;

              // محاولة جلب أول صورة للإعلان (عدل imagePath حسب اسم المتغير في الموديل الخاص بك)
              String? coverImage;
              if (product.images.toString() != 'null' && product.images.isNotEmpty) {
                // افترض أن الصورة تأتي كموديل أو كنص، عدلها حسب الموديل الخاص بك
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
                      // صورة الإعلان
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
                      // تفاصيل الإعلان في البطاقة
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomText(
                                title: product.title ?? 'بدون عنوان', // اسم الإعلان
                                fontWeight: FontWeight.bold,
                                size: fontSize - 4,
                                maxLines: 1, // لمنع خروج النص عن البطاقة
                              ),
                              CustomText(
                                title: '${product.price ?? 0} ريال', // السعر
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
                                      color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomText(
                                      title: isActive ? 'نشط' : 'موقوف',
                                      color: isActive ? Colors.green : Colors.red,
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

        // زر تحميل المزيد (Pagination)
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

  // =========================================================
  // الديالوج الكبير لعرض تفاصيل الإعلان (Responsive)
  // =========================================================

  void _showProductDetailsDialog(BuildContext context, AdsAdminVM vm, int productId, double fontSize) async {
    // 1. إظهار ديالوج التحميل أولاً
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // 2. جلب التفاصيل الكاملة من السيرفر
    final product = await vm.getProductDetails(productId);

    // إغلاق ديالوج التحميل
    if (context.mounted) Navigator.pop(context);

    if (product == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر جلب تفاصيل الإعلان')));
      return;
    }

    // 3. عرض نافذة التفاصيل
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
                    width: 800, // عرض كبير للويب
                    height: 600,
                    child: Column(
                      children: [
                        // الهيدر (العنوان وزر الإغلاق)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(title: 'تفاصيل الإعلان #${product.id}', fontWeight: FontWeight.bold, size: fontSize),
                              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                            ],
                          ),
                        ),

                        // المحتوى (مقسم لعمودين في الشاشات العريضة)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // العمود الأيمن: البيانات والنصوص
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

                                        // معلومات إضافية (المدينة، القسم، الخ)
                                        _buildInfoRow('القسم:', product.categoryName ?? '', fontSize),
                                        _buildInfoRow('المدينة:', product.cityName ?? '', fontSize),
                                        _buildInfoRow('تاريخ النشر:', formatTimeAgo(product.createdAt) ?? '', fontSize),
                                        _buildInfoRow('المشاهدات:', '${product.viewsCount ?? 0} مشاهدة', fontSize),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // العمود الأيسر: الصورة وحالة الإعلان (الأزرار)
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      // عرض الصورة الأولى بشكل كبير
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

                                      // زر إيقاف / تفعيل الإعلان
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: // داخل زر الإيقاف/الحظر في الديالوج
                                        ElevatedButton.icon(
                                          onPressed: vm.isActionLoading ? null : () => vm.blockOrUnblockAd(ctx, product.id ?? 0),
                                          icon: Icon(
                                            // 👈 هنا نفحص الحقل isBlocked (تأكد من وجوده في المودل)
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

  // عنصر مساعد لرسم سطر المعلومات
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