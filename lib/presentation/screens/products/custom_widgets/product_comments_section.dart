import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart'; // تأكد من المسار
import '../../../../configurations/data/end_points_manager.dart';
import '../../../../model/product_image_model.dart';
import '../../../../model/seller_model.dart';
import '../product_details_view_model.dart';

class ProductCommentsSection extends StatelessWidget {
  final List<ProductCommentModel> comments;

  const ProductCommentsSection({Key? key, required this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          const CustomText(
            title: 'التعليقات',
            size: 15.6,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F162A),
          ),
          // const SizedBox(height: 16),

          // قائمة التعليقات الموجودة
          if (comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CustomText(title: 'لا توجد تعليقات، كن أول من يعلق!', color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true, // مهم جداً داخل القوائم الأخرى
              physics: const NeverScrollableScrollPhysics(), // لتعطيل السكرول الداخلي
              itemCount: comments.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _CommentItem(comment: comments[index]);
              },
            ),

          const SizedBox(height: 20),

          // حقل إضافة التعليق الجديد
          const _CommentInputWidget(),
        ],
      ),
    );
  }
}

/// --- ويدجت التعليق الواحد (تصميم نظيف) ---
class _CommentItem extends StatelessWidget {
  final ProductCommentModel comment;
  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // نفس لون فيجما
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(comment.user?.profileImageUrl ?? EndPointsStrings.emptyImageUrl), // صورة افتراضية إذا لم توجد
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // المحتوى
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      title: comment.user?.fullName ?? 'مستخدم مجهول',
                      size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.current.blackGrey,
                    ),
                    // زر القائمة (اختياري من عندي لزيادة الاحترافية)
                    // const Icon(Icons.more_horiz, size: 16, color: Color(0xFF9CA2AE)),
                  ],
                ),
                const SizedBox(height: 4),
                CustomText(
                  title: comment.comment,
                  size: Theme.of(context).textTheme.bodySmall!.fontSize! - 3,
                  color: const Color(0xFF63748A),
                  maxLines: 10,
                ),
                const SizedBox(height: 4),
                CustomText(
                  title: comment.createdAt?.timeZoneName ?? 'منذ وقت قليل',
                  size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5,
                  color: const Color(0xFF9CA2AE),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --- ويدجت الإدخال (مع العداد والزر) ---
class _CommentInputWidget extends StatelessWidget {
  const _CommentInputWidget();

  @override
  Widget build(BuildContext context) {
    // نصل للـ ViewModel للتحكم في النص
    final vm = Provider.of<ProductDetailsViewModel>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20), // زوايا دائرية حسب التصميم
      ),
      child: Column(
        children: [
          // حقل النص
          TextField(
            controller: vm.commentController,
            onChanged: vm.updateCommentCount,
            maxLength: 255, // الحد الأقصى للنظام
            maxLines: null, // يتمدد مع النص
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              color: Color(0xFF0F162A),
            ),
            decoration: const InputDecoration(
              hintText: 'أكتب تعليقك على الإعلان...',
              hintStyle: TextStyle(
                color: Color(0xFF9CA2AE),
                fontSize: 11,
                fontFamily: 'Tajawal',
              ),
              border: InputBorder.none,
              counterText: "", // إخفاء العداد الافتراضي
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),

          // الصف السفلي (العداد + زر الإرسال)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // العداد اليدوي
              CustomText(
                title: '${vm.commentCharCount}/255',
                color: vm.commentCharCount >= 255 ? Colors.red : const Color(0xFF9CA2AE),
                size: 10,
                fontWeight: FontWeight.w500,
              ),

              // زر الإرسال
              InkWell(
                onTap: vm.commentCharCount > 0 ? vm.addComment : null,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 30, // تصغير الحجم قليلاً ليكون أنيقاً
                  height: 30,
                  decoration: BoxDecoration(
                    color: vm.commentCharCount > 0
                        ? const Color(0xFF2462EB) // أزرق مفعل
                        : const Color(0xFF9CA2AE).withOpacity(0.5), // رمادي غير مفعل
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 14), // استبدلت الـ SVG بأيقونة فلاتر لسهولة الاستخدام
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}