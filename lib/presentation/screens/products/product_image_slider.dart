import 'package:flutter/material.dart';

import '../../custom_widgets/custom_text.dart';

class ProductImageSlider extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final Function(int) onPageChanged;

  const ProductImageSlider({
    Key? key,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 256,
      child: Stack(
        children: [
          //رابط الصورة "لا يوجد منتج"

          PageView.builder(
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index], // 1. محاولة تحميل الصورة الأصلية
                fit: BoxFit.cover,
                width: double.infinity,
                // مؤشر التحميل (اختياري)
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },

                // ✅ 2. هنا المعالجة: إذا فشل التحميل، اعرض الصورة البديلة
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                   'https://2townsciderhouse.com/wp-content/themes/mx-theme/assets/img/no_product.png', // رابط الصورة "لا يوجد منتج"
                    fit: BoxFit.contain,
                    width: double.infinity,
                  );
                },

                // errorBuilder: (context, error, stackTrace) {
                //   return Image.asset(
                //     'assets/images/no_image_placeholder.png', // صورة محلية
                //     fit: BoxFit.cover,
                //     width: double.infinity,
                //   );
                // },
              );
            },
          ),

          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(
                  title: '${currentIndex + 1} / ${images.length}',
                  color: Colors.white,
                  size: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}