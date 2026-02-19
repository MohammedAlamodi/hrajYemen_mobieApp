// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../configurations/resources/font_manager.dart';

class CustomText extends StatelessWidget {
  final String? title;
  final Color? color;
  final double? size;
  final FontWeight? fontWeight;
  final int? maxLines;
  final double? letterSpacing;
  final double? textHeight;
  final bool? underLine;
  final bool? lineThrough;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;

  const CustomText({
    Key? key,
    this.title,
    this.color,
    this.size,
    this.fontFamily,
    this.letterSpacing,
    this.fontWeight,
    this.textHeight,
    this.maxLines,
    this.underLine,
    this.lineThrough = false,
    this.textAlign,
    this.textOverflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title == 'null'? '--' : '$title',
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines ?? 5,
      overflow: textOverflow ?? TextOverflow.ellipsis,
      textScaleFactor: 1.0,
      style: Theme.of(context).textTheme.bodySmall!.merge(TextStyle(
            letterSpacing: letterSpacing ?? 0,
            height: textHeight ?? 1.3,
            fontFamily: fontFamily ?? FontConstants.fontFamily,
            decoration: underLine != null
                ? TextDecoration.underline
                : lineThrough!
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
            fontSize: size ?? Theme.of(context).textTheme.bodyMedium!.fontSize,
            fontWeight: fontWeight ?? FontWeight.normal,
            color: color ?? Colors.black,
          )),
    );
  }
}
