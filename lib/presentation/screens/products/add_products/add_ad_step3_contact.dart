import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_text.dart';
import 'add_ad_view_model.dart';

class AddAdStep3Contact extends StatelessWidget {
  const AddAdStep3Contact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddAdViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          title: 'وسائل التواصل المتاحة',
          size: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF63748A),
        ),
        const SizedBox(height: 12),

        // خيارات التواصل
        // _buildSwitchTile(
        //   title: 'الدردشة داخل التطبيق',
        //   icon: Icons.chat_bubble_outline,
        //   value: vm.hasChat,
        //   onChanged: (v) => vm.toggleContactMethod('chat'),
        // ),
        // const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'اتصال هاتفي',
          icon: Icons.phone_in_talk_outlined,
          value: vm.hasCall,
          onChanged: (v) => vm.toggleContactMethod('call'),
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'واتساب',
          icon: Icons.wechat_outlined,
          value: vm.hasWhatsApp,
          onChanged: (v) => vm.toggleContactMethod('whatsapp'),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        // إظهار الرقم
        const CustomText(
          title: 'خصوصية الرقم',
          size: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF63748A),
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'إظهار رقم الجوال للجميع',
          icon: Icons.visibility_outlined,
          value: vm.showPhoneNumber,
          onChanged: (v) => vm.toggleContactMethod('showPhone'),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? Color(0xFFEEF6FF) : Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: value ? AppColors.current.blue : AppColors.current.grey,

              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              title: title,
              size: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2462EB),
          ),
        ],
      ),
    );
  }
}
