// import 'package:flutter/material.dart';
// import 'package:odoo_app/presentation/resources/app_colors.dart';
//
// import '../../../helpers_functions.dart';
// import '../custom_text.dart';
//
//
// class CustomBottomSheet extends StatelessWidget {
//   final String? title;
//   final Widget? bodyOfSheet;
//   final double? bottomSheetHeight;
//
//   const CustomBottomSheet(
//       {super.key,
//         this.title = '',
//         required this.bodyOfSheet,
//         this.bottomSheetHeight});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: Padding(
//           padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//           child: Container(
//             height: bottomSheetHeight ?? heightOfScreen(context) * 0.85,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(25),
//                 topRight: Radius.circular(25),
//               ),
//               color: AppColors.current.whiteColor,
//             ),
//             child: Column(
//               children: [
//                 Center(
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 5),
//                     height: 3,
//                     width: 75,
//                     color: AppColors.current.greyColor,
//                   ),
//                 ),
//
//                 // title
//                 Visibility(
//                   visible: title != '',
//                   replacement: const SizedBox(
//                     height: 20,
//                   ),
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(25),
//                         topRight: Radius.circular(25),
//                       ),
//                     ),
//                     margin: EdgeInsets.only(
//                         top: heightOfScreen(context) * 0.03,
//                         left: 5,
//                         right: 5,
//                         bottom: heightOfScreen(context) * 0.014),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // search title
//                         CustomText(
//                             title: title,
//                             size: Theme.of(context).textTheme.bodyLarge!.fontSize,
//                             fontWeight: FontWeight.w700
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // divider
//                 Visibility(
//                   visible: title != '',
//                   child: Center(
//                     child: Container(
//                       margin: const EdgeInsets.only(top: 5, bottom: 10),
//                       height: .5,
//                       width: widthOfScreen(context),
//                       color: AppColors.current.greyColor,
//                     ),
//                   ),
//                 ),
//
//                 Expanded(
//                   child: MediaQuery.removePadding(
//                     context: context,
//                     removeTop: true,
//                     child: bodyOfSheet!,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
