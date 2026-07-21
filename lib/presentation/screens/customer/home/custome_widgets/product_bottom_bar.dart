import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/helpers_functions.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/screens/customer/favorites/favorites_view_model.dart';

import '../../../../custom_widgets/custom_text.dart';

class ProductBottomBar extends StatelessWidget {
  final int productId;
  final VoidCallback onCallTap;
  final VoidCallback onChatTap;
  final VoidCallback onShareTap;
  final VoidCallback onFavoriteTap;
  final bool callEnabled; // false: الاتصال موقوف/الإعلان منتهي → زر رصاصي
  final bool chatEnabled; // false: الإعلان منتهي → زر رصاصي

  const ProductBottomBar({
    super.key,
    required this.productId,
    required this.onCallTap,
    required this.onChatTap,
    required this.onFavoriteTap,
    required this.onShareTap,
    this.callEnabled = true,
    this.chatEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    FavoritesViewModel favoritesViewModel = Provider.of<FavoritesViewModel>(context,);
    final isFav = favoritesViewModel.isFavorite(productId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE1E8EF))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // زر المراسلة (كبير ومميز) — يصير رصاصي إذا الإعلان منتهي
          ElevatedButton.icon(
            onPressed: onChatTap,
            icon: const Icon(Icons.wechat_outlined, size: 18, color: Colors.white),
            label: CustomText(
                title: 'مراسلة',
                color: Colors.white,
                size: Theme.of(context).textTheme.bodySmall!.fontSize,
                fontWeight: FontWeight.bold
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  chatEnabled ? AppColors.current.primary : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),

          // زر الاتصال — يصير رصاصي إذا الاتصال موقوف أو الإعلان منتهي
          OutlinedButton.icon(
            onPressed: onCallTap,
            icon: Icon(
                callEnabled
                    ? Icons.phone_in_talk_outlined
                    : Icons.phone_disabled_outlined,
                size: isTablet(context) ? 30 : 18,
                color: callEnabled ? Colors.green : Colors.grey),
            label: CustomText(
                title: 'اتصال',
                color: callEnabled ? AppColors.current.blackGrey : Colors.grey,
                size: Theme.of(context).textTheme.bodySmall!.fontSize,
                fontWeight: FontWeight.bold),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE1E8EF)),
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),

          // زر المشاركة/المفضلة (أيقونات صغيرة)
          _buildSmallIconBtn(Icons.share_outlined, onShareTap),
          const SizedBox(width: 8),
          InkWell(
            onTap: onFavoriteTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE1E8EF)),
              ),
              child: Icon(
                  isFav? Icons.favorite :
                  Icons.favorite_border,
                  size: isFav? 23 : 18,
                  color:  isFav? AppColors.current.primary : Color(0xFF63748A)),
            ),
          ),
          // _buildSmallIconBtn(Icons.favorite_border, onFavoriteTap),
        ],
      ),
    );
  }

  Widget _buildSmallIconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE1E8EF)),
        ),
        child: Icon(icon, color: const Color(0xFF63748A), size: 20),
      ),
    );
  }
}