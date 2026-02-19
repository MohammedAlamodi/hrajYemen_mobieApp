// import 'package:flutter/material.dart';
// import 'package:odoo_app/presentation/resources/app_colors.dart';
//
// import '../custom_text.dart';
//
//
// class CardOpenBottomSheet extends StatelessWidget {
//   final String? titleOutOfCard;
//   final String? title;
//   final bool? isInputError;
//   final String? errorTitle;
//   final Function()? onTap;
//   final EdgeInsetsGeometry? padding;
//   final double? borderRadius;
//   final Color? borderColor;
//   final double? height;
//   final double? size;
//
//   const CardOpenBottomSheet(
//       {super.key, this.titleOutOfCard, this.height, this.isInputError, this.errorTitle, this.size, this.title, this.borderRadius = 10, this.borderColor, this.onTap, this.padding});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//             if (titleOutOfCard != null) Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             child: CustomText( title: titleOutOfCard,
//               textAlign: TextAlign.start,
//               // size: Theme.of(context).textTheme.bodySmall!.fontSize! ,
//             ),
//           )
//             else const SizedBox(),
//
//           Container(
//             margin: padding ?? const EdgeInsets.symmetric(horizontal: 8),
//             height: height ?? 55,
//             decoration: BoxDecoration(
//                 border: Border.all(width: 1, color: borderColor ?? AppColors.current.primary),
//                 borderRadius: BorderRadius.circular(borderRadius!),
//                 color: AppColors.current.whiteColor),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: CustomText(
//                     title: title,
//                     size: size ?? Theme.of(context).textTheme.bodySmall!.fontSize,
//                     // fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Icon(Icons.arrow_drop_down_sharp)
//                 ),
//               ],
//             ),
//           ),
//
//           if (isInputError == true) Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: CustomText( title: errorTitle,
//             color: const Color(0xFF961C12),
//             textAlign: TextAlign.start,
//             size: Theme.of(context).textTheme.bodySmall!.fontSize! ,
//             ),
//           ) else const SizedBox()
//
//         ],
//       ),
//     );
//   }
// }
