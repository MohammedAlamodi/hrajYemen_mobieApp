import 'package:flutter/material.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';

/// حقل نصّي موحّد لنماذج المصادقة، يغلّف [CustomTextField] بحشوة قياسية.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      obscureText: obscureText,
      type: keyboardType,
      linesNumber: maxLines,
      readOnly: readOnly,
      hint: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }
}
