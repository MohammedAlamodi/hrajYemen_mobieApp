import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configurations/helpers_functions.dart';
import '../screens/common/common_view_model.dart';
import '../../configurations/resources/app_colors.dart';
import 'custom_text.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final double? elevation;
  final String? title;
  final double? titleSize;
  final VoidCallback? onLeadingTap;
  final Widget? leadingIcon;
  final List<Widget>? actionIcons;
  final double? leadingWidth;
  final bool? titleIsCenter;

  const CustomAppBar(
      {super.key,
        this.backgroundColor,
        this.elevation,
        this.title,
        this.leadingWidth=50,
        this.titleSize,
        this.leadingIcon,
        this.titleIsCenter,
        this.actionIcons,
        this.onLeadingTap });

  @override
  Widget build(BuildContext context) {
    CommonViewModel commonViewModel = Provider.of<CommonViewModel>(context, listen: false);

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.current.primary,
      elevation: elevation ?? 0.0,
      actions: actionIcons ?? [],
      leading: InkWell(
        onTap: onLeadingTap ?? () => Navigator.of(context).pop(),
        child: leadingIcon ??
            Icon(
              Icons.arrow_back,
              size:  isTablet(context) ? 45 : 36,
              color: Colors.white,
            ),
      ),
      title: CustomText(
        title: title ?? '',
        size: titleSize ?? Theme.of(context).textTheme.bodyMedium!.fontSize,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      centerTitle: true,
      leadingWidth: leadingWidth,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
