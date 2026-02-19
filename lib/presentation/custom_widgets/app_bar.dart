// import 'package:flutter/material.dart';
//
// import '../resources/color_manager.dart';
// import 'custom_text.dart';
//
//
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final Color? backgroundColor;
//   final double? elevation;
//   final String? title;
//   final double? titleSize;
//   final VoidCallback? onLeadingTap;
//   final Widget? leadingIcon;
//   final List<Widget>? actionIcons;
//   final double? leadingWidth;
//   final bool? titleIsCenter;
//
//   const CustomAppBar(
//       {super.key,
//         this.backgroundColor,
//         this.elevation,
//         this.title,
//         this.leadingWidth=50,
//         this.titleSize,
//         this.leadingIcon,
//         this.titleIsCenter,
//         this.actionIcons,
//         this.onLeadingTap });
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: backgroundColor ?? ColorManager.primary,
//       elevation: elevation ?? 0.0,
//       actions: actionIcons ?? [],
//       leading: InkWell(
//         onTap: onLeadingTap ?? () => Navigator.of(context).pop(),
//         child: leadingIcon ??
//             Icon(
//               Localizations.localeOf(context).languageCode == 'en'
//                   ? Icons.arrow_forward_rounded
//                   : Icons.arrow_back,
//               size:  36,
//               color: ColorManager.success,
//             ),
//       ),
//       title: CustomText(
//         title: title ?? '',
//         size: titleSize ?? Theme.of(context).textTheme.bodyMedium!.fontSize,
//         color: ColorManager.success,
//         fontWeight: FontWeight.w700,
//       ),
//       centerTitle: true,
//       leadingWidth: leadingWidth,
//     );
//   }
//
//   @override
//   // TODO: implement preferredSize
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
