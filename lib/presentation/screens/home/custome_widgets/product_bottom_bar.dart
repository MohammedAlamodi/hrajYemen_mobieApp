import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/helpers_functions.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';

import '../../../custom_widgets/custom_text.dart';

class ProductBottomBar extends StatelessWidget {
  final VoidCallback onCallTap;
  final VoidCallback onChatTap;
  final VoidCallback onWhatsAppTap;

  const ProductBottomBar({
    Key? key,
    required this.onCallTap,
    required this.onChatTap,
    required this.onWhatsAppTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // زر المراسلة (كبير ومميز)
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
              backgroundColor: const Color(0xFF2462EB),
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),

          // زر الاتصال
          OutlinedButton.icon(
            onPressed: onCallTap,
            icon: Icon(
                Icons.phone_in_talk_outlined,
                size: isTablet(context) ? 30 : 18, color:
                Colors.green
            ),
            label: CustomText(
                title: 'اتصال',
                color: AppColors.current.blackGrey,
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
          _buildSmallIconBtn(Icons.share_outlined, () {}),
          const SizedBox(width: 8),
          _buildSmallIconBtn(Icons.favorite_border, () {}),
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