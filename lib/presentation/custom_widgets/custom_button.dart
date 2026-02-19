import 'package:flutter/material.dart';

import '../../configurations/resources/app_colors.dart';
import 'custom_text.dart';
import '../../configurations/resources/font_manager.dart';
import 'loading_widgets.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final String? btnOneText1;
  final String? btnTwoText2;
  final bool btnTwoText;
  final bool textWithIcon;
  final bool textWithImage;
  final bool loading;
  final Icon? iconData;
  final String? image;
  final Color? btnColor, borderColor;
  final double? btnTextSize;
  final Color? btnTextColor;
  final Gradient? gradient;
  final FontWeight? btnTextFontWeight;
  final double? btnWidth, borderWidth, btnHeight, btnBorderRadius;

  const CustomButton(
      {Key? key,
      required this.onTap,
      this.btnColor,
      this.loading = false,
      this.iconData,
      this.textWithIcon = false,
      this.textWithImage = false,
      this.btnTwoText = false,
      this.btnBorderRadius,
      this.btnHeight,
      this.btnTextSize,
      this.btnTextColor,
      this.image,
      this.gradient,
      this.btnTextFontWeight,
      required this.text,
      this.btnOneText1,
      this.btnTwoText2,
      this.borderColor,
      this.borderWidth,
      this.btnWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: btnColor ?? AppColors.current.primary,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(btnBorderRadius ?? 15),
            // side: BorderSide(color: borderColor ?? AppColors.current.primary)
        ),
        textStyle: const TextStyle(color: Colors.white),
      ),
      child: btnTwoText
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                    title: btnOneText1 ?? '',
                    color: btnTextColor ?? Colors.white,
                    size: btnTextSize ??
                        Theme.of(context).textTheme.bodyMedium!.fontSize,
                    fontWeight: btnTextFontWeight ?? FontWeight.normal),
                CustomText(
                    title: btnTwoText2 ?? '',
                    color: btnTextColor ?? Colors.white,
                    size: btnTextSize ??
                        Theme.of(context).textTheme.bodyMedium!.fontSize,
                    fontWeight: btnTextFontWeight ?? FontWeight.normal),
              ],
            )
          : textWithIcon
              ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconData!,
                      SizedBox(width: MediaQuery.of(context).size.width * .05),
                      loading
                          ? const CustomLoadingWidget(
                        size: 25,
                      )
                          : CustomText(
                              title: text,
                              color: btnTextColor ?? Colors.white,
                              size: btnTextSize ??
                                  Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .fontSize,
                              fontWeight: btnTextFontWeight ?? FontWeight.normal),
                    ],
                  ),
              )
              : textWithImage
                  ? loading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CustomLoadingWidget(
                            size: 25,
                          )],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              image!,
                              height: 25,
                              color: Colors.white,
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .05),
                            CustomText(
                                title: text,
                                color: btnTextColor ?? Colors.white,
                                size: btnTextSize ??
                                    Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .fontSize,
                                fontWeight:
                                    btnTextFontWeight ?? FontWeight.normal
                            ),
                          ],
                        )
                  : Center(
                      child: loading
                          ? CustomLoadingWidget(
                        size: 25,
                      )
                          : Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: CustomText(
                                title: text,
                                textHeight: 1.0,
                                color:
                                    btnTextColor ?? Colors.white,
                                size: btnTextSize ??
                                    Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .fontSize,
                                fontWeight:
                                    btnTextFontWeight ?? FontWeightManager.w600,
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
    );
  }
}
