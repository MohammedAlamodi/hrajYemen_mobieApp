// Enum لحالة الإعلان
import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/get_amount_txt.dart';

import '../../../../custom_widgets/custom_text.dart';

enum AdStatus { active, sold, blocked }

class MyAdCard extends StatelessWidget {
  final String title;
  final double price;
  final String priceCurrency;
  final String date;
  final int views;
  final String imageUrl;
  final AdStatus status;
  final bool isBlocked;
  final VoidCallback? onEditTap;
  final VoidCallback? onRefTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onToggleStatusTap;

  const MyAdCard({
    super.key,
    required this.title,
    required this.price,
    required this.date,
    required this.priceCurrency,
    required this.isBlocked,
    required this.views,
    required this.imageUrl,
    required this.status,
    this.onEditTap,
    this.onRefTap,
    this.onDeleteTap,
    this.onToggleStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == AdStatus.active;

    final statusColor = isBlocked
        ? AppColors.current.error
          : isActive
        ? Colors.green
          : AppColors.current.error;
    final statusText = isBlocked
        ? 'تم حظره'
        : isActive
        ? 'نشط'
        : 'مباع / منتهي';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: Column(
        children: [
          // 1. الجزء العلوي (التفاصيل)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصورة
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF3F4F6),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // النصوص
                Expanded(
                  child: SizedBox(
                    height: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          title: title,
                          size: Theme.of(context).textTheme.bodySmall!.fontSize,
                          fontWeight: FontWeight.w800,
                          maxLines: 2,
                        ),
                        Row(
                          children: [
                            CustomText(
                              title: getAmountWithoutDot(price.toString()),
                              size:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.fontSize! +
                                  1,
                              fontWeight: FontWeight.w800,
                              color: AppColors.current.primary,
                            ),
                            CustomText(
                              title: ' ${priceCurrency} ',
                              size:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.fontSize! -
                                  5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.current.grey,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.current.blackGrey,
                            ),
                            const SizedBox(width: 4),
                            CustomText(
                              title: date,
                              size: 12,
                              color: AppColors.current.blackGrey,
                            ),
                            const Spacer(),
                            // حالة الإعلان (نص صغير)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: CustomText(
                                title: statusText,
                                color: statusColor,
                                size:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.fontSize! -
                                    3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. الجزء السفلي (الأزرار) - يظهر فقط إذا كان الإعلان نشطاً
          if (isActive && !isBlocked) ...[
            const Divider(height: 1, color: Color(0xFFE1E8EF)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // زر إنهاء الإعلان (تم البيع)
                  Expanded(
                    child: _buildActionButton(
                      text: 'تم البيع / إنهاء',
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                      onTap: onToggleStatusTap ?? () {},
                    ),
                  ),

                  const SizedBox(width: 8),

                  // زر التعديل
                  _buildActionButton(
                    text: 'تعديل',
                    icon: Icons.edit_outlined,
                    color: AppColors.current.blue,
                    onTap: onEditTap ?? () {},
                  ),

                  const SizedBox(width: 8),

                  // زر الحذف (دائماً موجود أو حسب رغبتك)
                  _buildActionButton(
                    icon: Icons.refresh,
                    color: AppColors.current.primary,
                    isIconOnly: true,
                    onTap: onRefTap ?? () {},
                  ),

                  const SizedBox(width: 8),

                  _buildActionButton(
                    icon: Icons.delete_outline,
                    color: AppColors.current.error,
                    isIconOnly: true,
                    onTap: onDeleteTap ?? () {},
                  ),
                ],
              ),
            ),
          ],

          // إذا كان منتهياً، ممكن نضيف مسافة بسيطة في الأسفل للشكل الجمالي
          if (!isActive) const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    String? text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isIconOnly = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: isIconOnly ? 0 : 12),
        width: isIconOnly ? 44 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE1E8EF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            if (!isIconOnly) ...[
              const SizedBox(width: 8),
              CustomText(
                title: text!,
                size: 13.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
