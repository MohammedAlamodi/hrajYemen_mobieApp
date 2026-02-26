import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';

import '../../common/common_view_model.dart';

class HomeCustomAppBar extends StatelessWidget {
  late CommonViewModel commonViewModel;

  HomeCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    commonViewModel = Provider.of<CommonViewModel>(context);

    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 20,),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             CustomText(
                title: commonViewModel.isLoggedIn ? 'مرحبا بك ${commonViewModel.currentUserName}' : '  مرحبا بك نورتنا',
                fontWeight: FontWeight.bold,
             ),

              // زر الإشعارات
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE1E8EF)),
                ),
                child: const Icon(Icons.notifications_outlined, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // حقل البحث
          CustomTextField(
            textAlign: TextAlign.right,
            hint: 'ابحث عن سيارة، جوال، شقة...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            labelText: 'ابحث عن سيارة، جوال، شقة...',
          ),
        ],
      ),
    );
  }
}