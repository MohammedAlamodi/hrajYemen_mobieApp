import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/configurations/user_preferences.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/screens/customer/home/main_wrapper_screen.dart';

/// زر "الدخول كزائر": يمسح أي جلسة/توكن سابق ثم يدخل التطبيق كزائر.
class GuestEntryButton extends StatelessWidget {
  const GuestEntryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          // امسح أي توكن/بيانات مستخدم سابقة قبل الدخول كزائر
          await UserPreferences().clearLogout(context);
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            MainWrapperScreen.routeName,
            (route) => false,
          );
        },
        child: CustomText(
          title: 'الدخول كزائر',
          size: Theme.of(context).textTheme.bodySmall!.fontSize,
          color: AppColors.current.primary,
        ),
      ),
    );
  }
}
