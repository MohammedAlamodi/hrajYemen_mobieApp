import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart'; // مكتبة ممتازة للحدود المنقطة (اختياري)
import '../../../custom_widgets/custom_text.dart';
import 'add_ad_view_model.dart';

class AddAdStep2Images extends StatelessWidget {
  const AddAdStep2Images({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddAdViewModel>(context);

    return Column(
      children: [
        // منطقة عرض وإضافة الصور
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          // +1 لزر الإضافة
          itemCount: vm.images.length + 1,
          itemBuilder: (context, index) {
            // زر الإضافة (أول عنصر)
            if (index == 0) {
              return InkWell(
                onTap: vm.pickImage,
                child: DottedBorder(
                  color: const Color(0xFF2462EB),
                  strokeWidth: 1,
                  dashPattern: const [6, 3],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: Color(0xFF2462EB)),
                          SizedBox(height: 4),
                          CustomText(title: 'أضف صورة', size: 10, color: Color(0xFF2462EB)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // عرض الصور المختارة
            final imageIndex = index - 1;
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(vm.images[imageIndex]), // صورة من الملف
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // زر الحذف
                Positioned(
                  top: 4, left: 4,
                  child: InkWell(
                    onTap: () => vm.removeImage(imageIndex),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
                // علامة الصورة الرئيسية
                if (imageIndex == 0)
                  Positioned(
                    bottom: 4, right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF2462EB), borderRadius: BorderRadius.circular(4)),
                      child: const CustomText(title: 'الرئيسية', size: 9, color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // نصائح الصور (موجودة في Figma)
        _buildTipsBox(),
      ],
    );
  }

  Widget _buildTipsBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFD)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title: 'نصائح للصور', size: 15, fontWeight: FontWeight.w800),
          SizedBox(height: 12),
          _TipItem(text: 'استخدم صور واضحة وعالية الجودة'),
          _TipItem(text: 'صور المنتج من زوايا مختلفة'),
          _TipItem(text: 'الحد الأقصى 10 صور لكل إعلان'),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 5, color: Color(0xFF2462EB)),
          const SizedBox(width: 8),
          CustomText(title: text, size: 13, color: Color(0xFF63748A)),
        ],
      ),
    );
  }
}