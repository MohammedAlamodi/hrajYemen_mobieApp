
import 'package:flutter/material.dart';
import 'package:ye_hraj/presentation/screens/common/auth/login/login_view.dart';

import '../../../configurations/resources/app_colors.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.current.appBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFEEF6FF), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, size: 60, color: Color(0xFF2462EB)),
              ),
              const SizedBox(height: 24),
              const CustomText(
                title: 'أهلاً بك يا زائر',
                size: 20,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 12),
              const CustomText(
                title: 'قم بتسجيل الدخول لتتمكن من إدارة إعلاناتك والتواصل مع البائعين.',
                textAlign: TextAlign.center,
                color: Color(0xFF63748A),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'تسجيل الدخول / إنشاء حساب',
                onTap: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }, // هنا تفتح صفحة اللوجن الحقيقية
                btnColor: const Color(0xFF2462EB),
                btnTextColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
