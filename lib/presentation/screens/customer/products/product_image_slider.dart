import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';

import '../../../custom_widgets/custom_text.dart';

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
          PageView.builder(
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, index) {
              String imageUrl = images[index];

              return GestureDetector(
                // ✅ 1. عند الضغط، نفتح شاشة العرض الاحترافية
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageGallery(
                        images: images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                // ✅ 2. استخدام Hero Animation لانتقال سلس جداً
                child: Hero(
                  tag: 'product_image_$index',
                  child: _buildImageWidget(imageUrl),
                ),
              );
            },
          ),

          // مؤشر الأرقام (1 / 3)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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

  // ✅ 3. فصلت بناء الصورة في دالة خارجية لنستخدمها في الشاشتين
  static Widget _buildImageWidget(String imageUrl, {BoxFit fit = BoxFit.cover}) {
    return imageUrl.toLowerCase().endsWith('.svg')
        ? SvgPicture.network(
      imageUrl,
      fit: fit,
      placeholderBuilder: (BuildContext context) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
      ),
    )
        : Image.network(
      imageUrl,
      fit: fit,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          EndPointsStrings.emptyImageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
        );
      },
    );
  }
}


class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageGallery({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // نبدأ من الصورة التي ضغط عليها المستخدم
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية احترافية داكنة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // زر إغلاق (X)
        leading: IconButton(
          icon: const Icon(Icons.close, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true, // لكي تأخذ الصورة كامل الشاشة تحت الـ AppBar
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              String imageUrl = widget.images[index];

              // ✅ سر التكبير الاحترافي هنا: InteractiveViewer
              return InteractiveViewer(
                minScale: 1.0,   // الحجم الطبيعي
                maxScale: 4.0,   // أقصى حد للتكبير
                // panEnabled: true, // مسموح بالسحب عند التكبير
                child: Hero(
                  tag: 'product_image_$index',
                  // استخدمنا BoxFit.contain لكي تظهر الصورة كاملة غير مقصوصة
                  child: ProductImageSlider._buildImageWidget(imageUrl, fit: BoxFit.contain),
                ),
              );
            },
          ),

          // عداد الصور في الأسفل (مثال: 1 / 4)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal', // أو الخط المستخدم لديك
                  ),
                  textDirection: TextDirection.ltr, // لضمان ظهور الأرقام بشكل صحيح
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}