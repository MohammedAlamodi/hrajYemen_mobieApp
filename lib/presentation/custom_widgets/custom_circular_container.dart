import 'package:flutter/material.dart';

import '../../configurations/resources/app_colors.dart';

class CustomCircularContainer extends StatelessWidget {
  Widget? child;
  Color? color;
  double? radius;
  double? height;
  double? width;
  double? padding;
  Function()? function;

  CustomCircularContainer(
      {super.key,
      this.child,
      this.color,
      this.radius,
      this.height,
      this.width,
      this.padding,
      this.function});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding ?? 8.0),
      child: GestureDetector(
        onTap: function,
        child: Container(
          height: height ?? 35,
          width: width ?? 35,
          decoration: BoxDecoration(
              color: color ?? AppColors.current.success,
              borderRadius: BorderRadius.circular(radius ?? 25)),
          child: child,
        ),
      ),
    );
  }
}
