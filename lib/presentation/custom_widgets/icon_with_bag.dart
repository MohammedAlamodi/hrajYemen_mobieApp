import 'package:flutter/material.dart';
import '../../configurations/helpers_functions.dart';
import 'custom_text.dart';

class CustomIconsWithBag extends StatelessWidget {
  final IconData icon;
  final Color color;
  final iconColor;
  final String? text;
  final double? iconSize;

  const CustomIconsWithBag(
      {Key? key,
      required this.icon,
      required this.color,
      this.iconColor,
      this.text,
      this.iconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: color,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              text != null
                  ? SizedBox(
                      width:
                          Theme.of(context).textTheme.bodySmall!.fontSize! + 10,
                      child: CustomText(
                        textAlign: TextAlign.end,
                        title: text,
                        fontWeight: FontWeight.bold,
                        size: Theme.of(context).textTheme.bodySmall!.fontSize,
                      ),
                    )
                  : SizedBox(),
              Icon(
                icon,
                color: iconColor ?? Colors.white,
                size: iconSize ?? (isPortrait(context)
                        ? widthOfScreen(context) * .045
                        : heightOfScreen(context) * .05),
                // size: iconSize !=null?iconSize: isPortrait(context) ? scrWidth(context) * .05 : scrHeight(context) * .05,
                // size: iconSize !=null?iconSize: isPortrait(context) ? scrWidth(context) * .05 : scrHeight(context) * .05,
              ),
            ],
          ),
        ));
  }
}
