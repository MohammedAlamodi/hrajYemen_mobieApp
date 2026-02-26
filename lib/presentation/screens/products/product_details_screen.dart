import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/model/user_model.dart';
import '../../custom_widgets/Custom_header_bar.dart';
import '../../custom_widgets/custom_text.dart';
import '../home/custome_widgets/product_bottom_bar.dart';
import 'custom_widgets/product_comments_section.dart';
import 'product_details_view_model.dart';
import 'product_image_slider.dart';

class ProductDetailsScreen extends StatelessWidget {
  // حولناها لـ Stateless لأن الـ VM يدير الحالة
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailsViewModel()..loadProductDetails(productId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<ProductDetailsViewModel>(
          builder: (context, vm, child) {
            // --- حالة التحميل (عرض الـ Skeleton) ---
            if (vm.isLoading) {
              return const _ProductDetailsSkeleton();
            }

            // --- حالة وجود البيانات (عرض الصفحة الحقيقية) ---
            final product = vm.productDetails;

            return product!=null?
            Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Header
                    const SliverToBoxAdapter(
                      child: CustomHeaderBar(
                        title: 'تفاصيل الإعلان',
                        showSearch: false,
                        onSearchChange: null,
                      ),
                    ),

                    // Slider
                    SliverToBoxAdapter(
                      child: ProductImageSlider(
                        images: product.images.map((img) => img.imageUrl).toList(),
                        currentIndex: vm.currentImageIndex,
                        onPageChanged: vm.onPageChanged,
                      ),
                    ),

                    // Body Content
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // السعر والعنوان
                          CustomText(
                            title: product.price.toString(),
                            fontWeight: FontWeight.w800,
                            color: AppColors.current.primary,
                          ),
                          const SizedBox(height: 8),
                          CustomText(
                            title: product.title,
                            fontWeight: FontWeight.w800,
                            size: Theme.of(
                              context,
                            ).textTheme.bodySmall!.fontSize,
                            color: AppColors.current.blackGrey,
                          ),

                          const SizedBox(height: 20),

                          // الموقع
                          _buildInfoBox(
                            context,
                            Icons.location_on_outlined,
                            'المدينة :',
                            '${product.cityName ?? ''} - ${product.regionName ?? ''}',
                          ),

                          const SizedBox(height: 16),

                          // التفاصيل
                          _buildSection(
                            context: context,
                            title: 'التفاصيل',
                            child: Column(
                              children: product.attributes.entries.map((e) {
                                return _buildAttributeRow(
                                  context,
                                  e.key,
                                  e.value,
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // الوصف
                          _buildSection(
                            context: context,
                            title: 'الوصف',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  title: product.description,
                                  color: const Color(0xFF63748A),
                                  textHeight: 1.6,
                                  size: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.fontSize,
                                  maxLines: vm.isDescriptionExpanded
                                      ? 100
                                      : 2,
                                ),
                                TextButton(
                                  onPressed: vm.toggleDescription,
                                  child: CustomText(
                                    title: vm.isDescriptionExpanded
                                        ? 'عرض أقل'
                                        : 'قراءة المزيد',
                                    size:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall!.fontSize! -
                                        2,
                                    color: const Color(0xFF2462EB),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // البائع
                          _buildSellerCard(
                            context: context,
                            sellerId: product.user?.id,
                            sellerName: product.user?.fullName ?? '-',
                            sellerPhone: product.user?.phoneNumber ?? '-',
                            sellerImageUrl: product.user?.profileImageUrl,
                          ),

                          const SizedBox(height: 16),

                          // استبدل _buildSectionContainer القديم الخاص بالتعليقات بهذا السطر:
                          ProductCommentsSection(comments: product.comments),
                          // مسافة للبار السفلي
                          const SizedBox(height: 100),
                        ]),
                      ),
                    ),
                  ],
                ),

                // البار السفلي
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ProductBottomBar(
                    onCallTap: () {},
                    onChatTap: () {
                      vm.startChatWithSeller(context, product);
                    },
                    onWhatsAppTap: () {},
                  ),
                ),
              ],
            ) :
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomText(
                    title: 'حدث خطأ أثناء تحميل تفاصيل المنتج.',
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => vm.loadProductDetails(productId),
                    child: const CustomText(title: 'إعادة المحاولة'),
                  ),
                ],
              )
            );
          }
        ),
      ),
    );
  }

  // --- Widgets مساعدة للصفحة (نفس الكود السابق لترتيب الكود) ---
  Widget _buildInfoBox(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E8EF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          CustomText(
            title: label,
            fontWeight: FontWeight.bold,
            size: Theme.of(context).textTheme.bodySmall!.fontSize,
          ),
          const SizedBox(width: 8),
          CustomText(
            title: value,
            color: Colors.grey,
            size: Theme.of(context).textTheme.bodySmall!.fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E8EF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title: title,
            size: Theme.of(context).textTheme.bodySmall!.fontSize,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildAttributeRow(BuildContext context, String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            title: key,
            color: Colors.grey,
            size: Theme.of(context).textTheme.bodySmall!.fontSize,
          ),
          CustomText(
            title: value,
            fontWeight: FontWeight.bold,
            size: Theme.of(context).textTheme.bodySmall!.fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard({
    required BuildContext context,
    String? sellerId,
    String? sellerName,
    String? sellerPhone,
    String? sellerImageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title: 'البائع',
              size: Theme.of(context).textTheme.bodySmall!.fontSize,
              fontWeight: FontWeight.bold
          ),
          SizedBox(height: 10,),

          Row(
            children: [
              CircleAvatar(
                  backgroundImage:
                  NetworkImage(sellerImageUrl ?? EndPointsStrings.emptyImageUrl),
              ),
              const SizedBox(width: 10),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title: sellerName ?? '-',
                    size: Theme.of(context).textTheme.bodySmall!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),

                  SizedBox(height: 10,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.phone_outlined, color: Colors.green,
                            size: Theme.of(context).textTheme.bodySmall!.fontSize! + 3
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CustomText(
                          title: sellerPhone ?? '-',
                          size: Theme.of(context).textTheme.bodySmall!.fontSize,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }
}

/// -----------------------------------------------------------------
/// ✅ Skeleton Widget (اللودينق الاحترافي)
/// محاكاة لشكل الصفحة ولكن بمربعات رمادية وامضة
/// -----------------------------------------------------------------
class _ProductDetailsSkeleton extends StatefulWidget {
  const _ProductDetailsSkeleton({super.key});

  @override
  State<_ProductDetailsSkeleton> createState() =>
      _ProductDetailsSkeletonState();
}

class _ProductDetailsSkeletonState extends State<_ProductDetailsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // أنيميشن تكراري للشفافية (تأثير النبض)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // تغيير الشفافية بين 0.5 و 1.0 لعمل تأثير اللمعان
        return Opacity(opacity: 0.5 + (_controller.value * 0.5), child: child);
      },
      child: Column(
        children: [
          const CustomHeaderBar(
              title: 'تفاصيل الإعلان',
              showSearch: false,
            onSearchChange: null,
          ),
          // هيدر وهمي
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. مربع مكان الصورة (كبير)
                  _buildBox(height: 250, width: double.infinity),
                  const SizedBox(height: 16),

                  // 2. سطر السعر (قصير)
                  _buildBox(height: 24, width: 150),
                  const SizedBox(height: 8),

                  // 3. سطر العنوان (طويل)
                  _buildBox(height: 24, width: 300),
                  const SizedBox(height: 16),

                  // 4. بوكس الموقع
                  _buildBox(height: 50, width: double.infinity),
                  const SizedBox(height: 16),

                  // 5. بوكس التفاصيل (كبير)
                  _buildBox(height: 150, width: double.infinity),
                  const SizedBox(height: 16),

                  // 6. بوكس البائع
                  Row(
                    children: [
                      _buildBox(height: 50, width: 50, isCircle: true),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBox(height: 15, width: 100),
                          const SizedBox(height: 5),
                          _buildBox(height: 10, width: 60),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // بار سفلي وهمي
          Container(height: 80, color: Colors.grey.shade100),
        ],
      ),
    );
  }

  // ويدجت بسيطة لرسم المربعات الرمادية
  Widget _buildBox({
    required double height,
    required double width,
    bool isCircle = false,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // لون رمادي فاتح
        borderRadius: BorderRadius.circular(isCircle ? height : 8),
      ),
    );
  }
}
