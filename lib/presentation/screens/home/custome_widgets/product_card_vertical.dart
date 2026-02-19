import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/get_amount_txt.dart';

import '../../../../model/category_model.dart';

import 'package:flutter/material.dart';
import '../../../../model/product_image_model.dart';
import '../../../../model/product_model.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../favorites/favorites_view_model.dart';

class ProductCardVertical extends StatefulWidget {
  final ProductModel product;

  const ProductCardVertical({super.key, required this.product});

  @override
  State<ProductCardVertical> createState() => _ProductCardVerticalState();
}

class _ProductCardVerticalState extends State<ProductCardVertical> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // تجهيز قائمة الصور
    final List<ProductImageModel> images = widget.product.images.isNotEmpty
        ? widget.product.images
        : [ProductImageModel(
      id: 0,
      productId: widget.product.id,
      imageUrl: 'https://2townsciderhouse.com/wp-content/themes/mx-theme/assets/img/no_product.png',
      isMain: true,
    )];

    return Consumer<FavoritesViewModel>(
      builder: (context, favVM, child) {

        final isFav = favVM.isFavorite(widget.product.id);

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. منطقة الصورة (تم تحويلها لـ Slider)
              Expanded(
                child: Stack(
                  children: [
                    // عارض الصور
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Container(
                        color: const Color(0xFFF3F4F6), // لون خلفية أثناء التحميل
                        width: double.infinity,
                        child: PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index].imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: Icon(Icons.image, color: Colors.grey, size: 30));
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // مؤشر النقاط (يظهر فقط اذا فيه اكثر من صورة)
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
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // زر المفضلة (إضافة جمالية اختيارية فوق الصورة)
                    Positioned(
                      top: 8,
                      left: 8, // أو right حسب اتجاه التطبيق
                      child: InkWell(
                        onTap: (){
                          favVM.toggleFavorite(widget.product);
                          },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isFav?  AppColors.current.primary50 : Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                              isFav? Icons.favorite :
                              Icons.favorite_border,
                              size: isFav? 23 : 18,
                              color:  isFav? AppColors.current.primary : Color(0xFF63748A)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. التفاصيل (نفس الكود السابق تماماً)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title: widget.product.title,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w800,
                      size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      title: getAmountWithoutDot(widget.product.price.toString()),
                      maxLines: 1,
                      fontWeight: FontWeight.w800,
                      size: Theme.of(context).textTheme.bodyMedium!.fontSize! - 3,
                      color: const Color(0xFF2462EB),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          title: formatTimeAgo(widget.product.createdAt),
                          color: const Color(0xFF63748A),
                          size: Theme.of(context).textTheme.bodyMedium!.fontSize! - 5,
                        ),
                        CustomText(
                          title: '${widget.product.city?.name ?? ''} - ${widget.product.region?.name ?? ''}',
                          color: const Color(0xFF63748A),
                          size: Theme.of(context).textTheme.bodyMedium!.fontSize! - 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// class ProductCardVertical extends StatelessWidget {
//   final ProductModel product;
//
//   const ProductCardVertical({super.key, required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
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
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // صورة المنتج
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF3F4F6),
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                 image: DecorationImage(
//                   image: NetworkImage(product.imageUrl),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           // التفاصيل
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomText(
//                   // title: 'product.title product.title, product.title,',
//                   title: product.title,
//                   maxLines: 1,
//                   textOverflow: TextOverflow.ellipsis,
//                     fontWeight: FontWeight.w800,
//                   size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
//                 ),
//                 const SizedBox(height: 4),
//                 CustomText(
//                   title: product.price,
//                   // title: 'product.price product.price product.price',
//                     maxLines: 1,
//                     fontWeight: FontWeight.w800,
//                   size: Theme.of(context).textTheme.bodyMedium!.fontSize! - 3,
//                     color: Color(0xFF2462EB),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CustomText(
//                       title: product.timeAgo,
//                    color: Color(0xFF63748A),
//                       size: Theme.of(context).textTheme.bodyMedium!.fontSize! - 5,
//                     ),
//                     CustomText(
//                       title:
//                       product.location,
//                       color: Color(0xFF63748A),
//                       size: Theme.of(context).textTheme.bodyMedium!.fontSize! - 5,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }