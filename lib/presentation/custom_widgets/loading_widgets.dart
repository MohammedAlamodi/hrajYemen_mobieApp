import 'package:flutter/material.dart';

import '../../configurations/resources/app_colors.dart';
import 'custom_text.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? size;
  final double? textSize;

  const CustomLoadingWidget({super.key, this.text , this.color, this.size, this.textSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  color: AppColors.current.primary,
                  valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.current.success.withOpacity(0.8)),
                ),
              ),
              const SizedBox(height: 10,),
              text != null ? CustomText(
                title: text,
                size: textSize ?? Theme.of(context).textTheme.bodyMedium!.fontSize,
                color: color ?? AppColors.current.success,
              ) : const SizedBox()
            ],
          ),
        ));
  }
}

class CustomLoadingHorzWidget extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? size;
  final double? textSize;

  const CustomLoadingHorzWidget({super.key, this.text , this.color, this.size, this.textSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  color: AppColors.current.primary,
                  valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.current.success.withOpacity(0.8)),
                ),
              ),
              const SizedBox(width: 10,),
              text != null ? CustomText(
                title: text,
                size: textSize ?? Theme.of(context).textTheme.bodyMedium!.fontSize,
                color: color ?? AppColors.current.success,
              ) : const SizedBox()
            ],
          ),
        ));
  }
}
