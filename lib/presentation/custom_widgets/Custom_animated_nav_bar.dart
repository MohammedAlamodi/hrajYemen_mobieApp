import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';

class CustomAnimatedNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback onAddAdTapped; // زر الإضافة له تعامل خاص

  const CustomAnimatedNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddAdTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // ارتفاع البار
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context,0, Icons.home, 'الرئيسية'),
          _buildNavItem(context,1, Icons.favorite_border_rounded, 'المفضلة'),

          // --- الزر العائم في المنتصف (إضافة إعلان) ---
          GestureDetector(
            onTap: onAddAdTapped,
            child: Transform.translate(
              offset: const Offset(0, -25), // رفعه للأعلى قليلاً
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2462EB), // اللون الأزرق الرئيسي
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.current.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),

          _buildNavItem(context,2, Icons.wechat_outlined, 'الدردشة'),
          _buildNavItem(context,3, Icons.person_rounded, 'حسابي'),
        ],
      ),
    );
  }

  // عنصر التنقل الواحد (مع أنيميشن)
  Widget _buildNavItem(BuildContext context,int index, IconData icon, String label) {
    bool isSelected = selectedIndex == index;

    // ملاحظة: الأندكسات هنا تحتاج تعديل بسيط لأن زر الإضافة في الوسط
    // 0: home, 1: favorites, (Button), 2: chat, 3: profile

    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.current.primary : const Color(0xFF9CA2AE),
              size: isSelected ? 26 : 22, // تكبير الأيقونة عند الاختيار
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: isSelected ?  Theme.of(context).textTheme.bodySmall!.fontSize! - 3 : Theme.of(context).textTheme.bodySmall!.fontSize! - 6,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? AppColors.current.primary : const Color(0xFF9CA2AE),
                  ),

              // TextStyle(
              //   fontFamily: 'Tajawal',
              //   fontSize: 11,
              //   fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              //   color: isSelected ? const AppColors.current.primary : const Color(0xFF9CA2AE),
              // ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}