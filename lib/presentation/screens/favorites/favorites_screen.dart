import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import '../../custom_widgets/Custom_header_bar.dart';
import '../../custom_widgets/custom_text.dart';
import '../home/custome_widgets/Product_list_viewer.dart'; // مسار الكستم ويدجت
import 'favorites_view_model.dart'; // الهيدر

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // الهيدر (يمكن تغييره لهيدر بسيط اذا اردت)
          const CustomHeaderBar(
            title: 'المفضلة',
            showSearch: false,
            showBack: false,
            onSearchChange: null,
          ),

          SizedBox(height: 10,),

          Expanded(
            child: Consumer<FavoritesViewModel>(
              builder: (context, favVM, child) {
                // الحالة 1: القائمة فارغة
                if (favVM.favorites.isEmpty) {
                  return _buildEmptyState(context);
                }
                // الحالة 2: يوجد منتجات (نستخدم الويدجت الجاهز)
                return ProductListViewer(
                  title: 'المنتجات المحفوظة (${favVM.favorites.length})',
                  products: favVM.favorites,
                  // لا نحتاج بيجنيشن هنا لأن البيانات لوكل
                  isLoadingMore: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت الحالة الفارغة (تصميم جميل)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.current.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 50,
              color: AppColors.current.primary,
            ),
          ),
          const SizedBox(height: 24),
          const CustomText(
            title: 'المفضلة فارغة!',
            // size: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F162A),
          ),
          const SizedBox(height: 8),
          CustomText(
            title:
                'لم تقم بحفظ أي إعلانات حتى الآن.\nتصفح الإعلانات واحفظ ما يعجبك.',
            textAlign: TextAlign.center,
            size: Theme.of(context).textTheme.bodySmall!.fontSize,
            color: Color(0xFF63748A),
            // height: 1.5,
          ),
        ],
      ),
    );
  }
}
