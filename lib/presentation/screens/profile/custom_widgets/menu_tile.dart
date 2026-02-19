import 'package:flutter/material.dart';

import '../../../custom_widgets/custom_text.dart';

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  bool isDestructive;

  MenuTile({super.key,
    this.isDestructive = false,
    required this.icon,
    required this.title,
    required this.onTap,

  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFEEF6FF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive
              ? Colors.red
              : const Color(0xFF2462EB), // لون أحمر للحذف
        ),
      ),
      title: CustomText(
        title: title,
        size: 15,
        fontWeight: FontWeight.w600,
        color: isDestructive ? Colors.red : const Color(0xFF0F162A),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF9CA2AE),
      ),
    );
  }
}
