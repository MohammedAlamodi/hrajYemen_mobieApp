import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  final VoidCallback onTap;
  final int colorValue;
  final double? heightAndWidthValue;
  final IconData iconData;
  const CustomInkWell({super.key, required this.onTap, this.heightAndWidthValue,required this.colorValue,required this.iconData,});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          width: heightAndWidthValue ?? 60,
          height: heightAndWidthValue ?? 65,
          decoration: BoxDecoration(
              color: Color(colorValue),
              borderRadius:
              BorderRadius
                  .circular(
                  12)),
          child: Icon(
            iconData,
            color:
            Colors.white,
            size: heightAndWidthValue == null? 36 : heightAndWidthValue! / 2,
          ),
        ),
      ),
    );
  }
}
