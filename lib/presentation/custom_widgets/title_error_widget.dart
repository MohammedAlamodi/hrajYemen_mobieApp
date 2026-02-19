import 'package:flutter/material.dart';

import '../../configurations/resources/app_colors.dart';
import 'custom_text.dart';

class TitleErrorWidget extends StatelessWidget {
  final String? title;
  const TitleErrorWidget({super.key,this.title,});

  @override
  Widget build(BuildContext context) {
    return CustomText(
        title: title,
        color: AppColors.current.error,
        textAlign: TextAlign.center,
        size: Theme.of(context).textTheme.bodySmall!.fontSize
    );
  }
}
