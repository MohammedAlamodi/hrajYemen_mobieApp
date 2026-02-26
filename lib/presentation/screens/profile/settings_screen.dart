import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';

import '../../custom_widgets/Custom_header_bar.dart';
import '../../custom_widgets/custom_text.dart';
import 'custom_widgets/menu_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.current.appBackground,
      body: Column(
        children: [
          CustomHeaderBar(
            title: 'الإعدادات',
            showSearch: false,
            onSearchChange: null,
          ),

          SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE1E8EF)),
              ),
              child: Column(
                children: [
                  MenuTile(
                    icon: Icons.language,
                    title: 'تغيير اللغة',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  MenuTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'حذف حسابي',
                    onTap: () {},
                    isDestructive: true, // لون أحمر
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 60);
  }

}
