import 'package:flutter/material.dart';

import '../../configurations/resources/app_colors.dart';

class FloatActionButtonCustom extends StatelessWidget {
  const FloatActionButtonCustom({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      child: SizedBox(
        // width: isTablet(context)? 80: 60.0,
        width: 60.0,
        // height: isTablet(context)? 80: 60.0,
        height: 60.0,
        child: FloatingActionButton(
          backgroundColor: AppColors.current.primary,
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.add,
              color: AppColors.current.success,
              // size: isTablet(context)? 45: 35,
              size: 35,
            ),
          ),
        ),
      ),
    );
  }
}
