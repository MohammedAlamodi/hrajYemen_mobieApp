import 'package:flutter/material.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';

/// عنوان حقل في نماذج المصادقة (التسجيل/التعديل) مع علامة الإجبارية أو (اختياري).
class AuthFieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const AuthFieldLabel({
    super.key,
    required this.text,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final double baseSize = Theme.of(context).textTheme.bodySmall!.fontSize!;
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          CustomText(
            title: text,
            size: baseSize - 2,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F162A),
          ),
          isRequired
              ? const Text(' *', style: TextStyle(color: Colors.red))
              : CustomText(
                  title: '  (إختياري)  ',
                  size: baseSize - 3,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                ),
        ],
      ),
    );
  }
}
