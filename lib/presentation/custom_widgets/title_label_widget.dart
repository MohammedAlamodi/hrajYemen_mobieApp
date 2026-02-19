import 'package:flutter/material.dart';

import 'custom_text.dart';

class LabelTitleWidget extends StatelessWidget {
  final String? title;
  final String? optionalTitle;
  final bool? isOptionalTitle;
  final bool? labelIsRequiredTitle;
  final double? paddingFromLabel;
  final Color? color;

  const LabelTitleWidget({
    Key? key,
    this.optionalTitle = '',
    this.isOptionalTitle = false,
    this.paddingFromLabel,
    this.labelIsRequiredTitle = false,
    this.title,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: 8,
          bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomText(
            title: title!,
            color: color ?? Colors.black,
            // fontWeight: FontWeightManager.regular,
            size: Theme.of(context).textTheme.bodyLarge!.fontSize,
          ),
          labelIsRequiredTitle!
              ? const Text(
            '*',
            style: TextStyle(color: Colors.red),
          )
              : Container(),
        ],
      ),
    );
  }
}
