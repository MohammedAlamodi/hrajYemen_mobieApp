import 'package:flutter/material.dart';

import '../../../custom_widgets/custom_text.dart';

class AttributeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const AttributeRow({Key? key, required this.label, required this.value, this.isLast = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(title: label, color: const Color(0xFF63748A), size: 13.5),
              CustomText(title: value, color: const Color(0xFF0F162A), size: 13.8, fontWeight: FontWeight.w600),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}