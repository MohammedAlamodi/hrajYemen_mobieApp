import 'package:flutter/material.dart';

class CustomAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double iconSize;

  const CustomAvatarWidget({
    super.key,
    required this.imageUrl,
    this.size = 70.0, // الحجم الافتراضي
    this.iconSize = 35.0, // حجم الأيقونة الافتراضية
  });

  @override
  Widget build(BuildContext context) {
    // التأكد من أن الرابط ليس null وليس نصاً فارغاً
    final bool hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6), // لون خلفية رمادي فاتح
        shape: BoxShape.circle,
      ),
      // ✂️ مهم جداً: هذا السطر هو الذي يقص الصورة لتصبح دائرية تماماً
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        // ⚠️ في حال كان الرابط مكسوراً أو السيرفر لا يستجيب
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
        // ⏳ أثناء تحميل الصورة من الإنترنت
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child; // تم التحميل
          return Center(
            child: SizedBox(
              width: size * 0.4, // حجم مؤشر التحميل متناسب مع حجم الأفاتار
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: const Color(0xFF2462EB).withOpacity(0.5),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
      )
          : _buildDefaultIcon(), // إذا كان الرابط null من الأساس
    );
  }

  // تصميم الأيقونة الافتراضية (إذا لم توجد صورة أو فشل التحميل)
  Widget _buildDefaultIcon() {
    return Center(
      child: Icon(
        Icons.person,
        size: iconSize,
        color: const Color(0xFF9CA2AE), // لون رمادي أنيق
      ),
    );
  }
}