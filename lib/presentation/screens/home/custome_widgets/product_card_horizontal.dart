import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_avatar.dart';

import '../../../../model/category_model.dart';
import '../../../../model/product_image_model.dart';
import '../../../../model/product_model.dart';
import '../../../custom_widgets/custom_text.dart';

import 'package:flutter/material.dart';
import '../../../../model/product_model.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../favorites/favorites_view_model.dart';

class ProductCardHorizontal extends StatefulWidget {
  final ProductModel product;

  const ProductCardHorizontal({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCardHorizontal> createState() => _ProductCardHorizontalState();
}

class _ProductCardHorizontalState extends State<ProductCardHorizontal> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // نستخدم قائمة الصور من الموديل، إذا كانت فارغة نستخدم الصورة الفردية كاحتياط
    final List<ProductImageModel> images = widget.product.images.isNotEmpty
        ? widget.product.images
        : [ProductImageModel(
          id: 0,
          productId: widget.product.id,
          imageUrl: 'https://2townsciderhouse.com/wp-content/themes/mx-theme/assets/img/no_product.png',
        isMain: true,
      )];
        // : ['https://2townsciderhouse.com/wp-content/themes/mx-theme/assets/img/no_product.png'];

    return Consumer<FavoritesViewModel>(
        builder: (context, favVM, child) {
          final isFav = favVM.isFavorite(widget.product.id);

          return Container(
          height: 125, // تحديد ارتفاع للكارد لضمان تناسق الـ PageView
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E8EF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. منطقة صور المنتج (سلايدر)
              Container(
                width: 125, // عرض مربع الصورة
                decoration: const BoxDecoration(
                  // لا نحتاج لون هنا لأن الصورة ستغطي، لكن يمكن وضعه كخلفية تحميل
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12), // لأن التطبيق عربي RTL
                  ),
                ),
                child: Stack(
                  children: [
                    // عارض الصور القابل للسحب
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          String imageUrl = images[index].imageUrl;
                          return imageUrl.toLowerCase().endsWith('.svg')
                              ? SvgPicture.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            placeholderBuilder: (BuildContext context) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                              : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),

                    // مؤشر النقاط (Dots Indicator) - يظهر فقط لو فيه أكثر من صورة
                    if (images.length > 1)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: images.asMap().entries.map((entry) {
                            return Container(
                              width: 6.0,
                              height: 6.0,
                              margin: const EdgeInsets.symmetric(horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == entry.key
                                    ? Colors.white // النقطة النشطة
                                    : Colors.white.withOpacity(0.4), // النقاط غير النشطة
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              // 2. التفاصيل (نفس كودك السابق مع تحسينات طفيفة)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // العنوان
                      CustomText(
                        title: widget.product.title,
                        fontWeight: FontWeight.w800,
                        size: Theme.of(context).textTheme.bodySmall!.fontSize!,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),

                      // السعر
                      CustomText(
                        title: widget.product.price.toString(),
                        size: Theme.of(context).textTheme.bodySmall!.fontSize! + 1, // تكبير بسيط للسعر
                        fontWeight: FontWeight.w800,
                        color: AppColors.current.blue,
                      ),

                      // الصف السفلي (موقع، وقت، مفضلة)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end, // محاذاة لأسفل الصف
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // الموقع
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF63748A)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: CustomText(
                                        title: '${widget.product.cityName ?? ''} - ${widget.product.regionName ?? ''}',
                                        size: 10,
                                        color: const Color(0xFF63748A),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // الوقت
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 12, color: Color(0xFF63748A)),
                                    const SizedBox(width: 4),
                                    CustomText(
                                      title: formatTimeAgo(widget.product.createdAt),
                                      size: 10,
                                      color: const Color(0xFF63748A),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // زر المفضلة (تم تصغير الـ Padding ليناسب المساحة)
                          InkWell(
                            onTap: () {
                              favVM.toggleFavorite(widget.product);
                              },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon( isFav ? Icons.favorite_sharp :
                                  Icons.favorite_border, size: 20, color: isFav ? AppColors.current.primary : Color(0xFF9CA2AE)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// class ProductCardHorizontal extends StatelessWidget {
//   final ProductModel product;
//
//   const ProductCardHorizontal({Key? key, required this.product}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // height: 120, // ارتفاع ثابت للكارد الأفقي
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE1E8EF)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 2,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // 1. الصورة (تأخذ مساحة محددة)
//           CustomProductImageAvatar(
//               image: product.imageUrl,
//               fromNetwork: true,
//               widthAndHeight: 120),
//
//           // 2. التفاصيل
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   CustomText(
//                     // title: 'product title product ßtitle product title product title product title product title',
//                     title: product.title,
//                     fontWeight: FontWeight.w800,
//                     size: Theme.of(context).textTheme.bodySmall!.fontSize!,
//                     maxLines: 2,
//                   ),
//                   const SizedBox(height: 6),
//                   CustomText(
//                     title: product.price,
//                     size: Theme.of(context).textTheme.bodySmall!.fontSize!,
//                     fontWeight: FontWeight.w800,
//                     color: const Color(0xFF2462EB),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   // الموقع والوقت
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF63748A)),
//                           const SizedBox(width: 4),
//                           CustomText(
//                             title: product.location,
//                             size: Theme.of(context).textTheme.bodySmall!.fontSize! - 3,
//                             color: const Color(0xFF63748A),
//                           ),
//                         ],
//                       ),
//                       CustomText(
//                         title: product.timeAgo,
//                         size: Theme.of(context).textTheme.bodySmall!.fontSize! - 3,
//                         color: const Color(0xFF63748A),
//                       ),
//
//                       IconButton(
//                           onPressed: (){},
//                           icon: Icon(Icons.favorite)
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }