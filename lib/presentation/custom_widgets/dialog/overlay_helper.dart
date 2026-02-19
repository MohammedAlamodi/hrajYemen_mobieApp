// // ignore_for_file: prefer_final_fields
//
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import '../../custom_widgets/custom_dialog.dart';
// import '../full_flex.dart';
// // import 'package:get/get.dart';
//
// abstract class OverlayHelper {
//   OverlayHelper._();
//
//   static final Map<int, OverlayEntry?> _lastOverlays = {};
//
//   static Color successColor = const Color.fromRGBO(46, 204, 113, 1);
//   static Color errorColor = const Color.fromRGBO(231, 76, 60, 1);
//   static Color infoColor = const Color.fromRGBO(17, 110, 183, 1);
//   static Color warningColor = const Color.fromRGBO(241, 196, 15, 1);
//
//   static int _toastLayerIndex = 2, _progressLayerIndex = 1;
//
//   static void showOverlay(
//       {required BuildContext context,
//         int? durationInSeconds,
//         int layerIndex = 0,
//         required Widget widget}) {
//     var overlay = OverlayEntry(builder: (_) => widget);
//
//     if (_lastOverlays[layerIndex] != null) {
//       _lastOverlays[layerIndex]!.remove();
//       _lastOverlays[layerIndex] = null;
//     }
//     var o = Overlay.of(context);
//     if (o == null) {
//       return;
//     }
//     o.insert(overlay);
//     _lastOverlays[layerIndex] = overlay;
//
//     if (durationInSeconds == null) return;
//
//     Future.delayed(Duration(seconds: durationInSeconds), () {
//       if (_lastOverlays[layerIndex] == null ||
//           _lastOverlays[layerIndex] != overlay) return;
//       _lastOverlays[layerIndex]!.remove();
//       _lastOverlays[layerIndex] = null;
//     });
//   }
//
//   static void hideOverlay([int layerIndex = 0]) {
//     if (_lastOverlays[layerIndex] != null) {
//       _lastOverlays[layerIndex]!.remove();
//       _lastOverlays[layerIndex] = null;
//     }
//   }
//
//   static void hideAllOverlays() {
//     for (int index in _lastOverlays.keys) {
//       hideOverlay(index);
//     }
//   }
//
//   // toast methods
//   static void showToast2({
//     required String message,
//     Color? backgroundColor,
//   }) {
//     Fluttertoast.showToast(
//       msg: "$message", // message;
//       textColor: const Color(0xFF2B6192),
//       backgroundColor: const Color(0xFFFF3331),
//
//       toastLength: Toast.LENGTH_LONG, // length
//       gravity: ToastGravity.BOTTOM, // location
//     );
//   }
//
//   static void showToast(BuildContext context, String text, Color color,
//       IconData icon, int durationInSeconds) {
//     showOverlay(
//         context: context,
//         durationInSeconds: durationInSeconds,
//         layerIndex: _toastLayerIndex,
//         widget: OverlayToast(text, color, icon));
//   }
//
//   static void showSuccessToast(BuildContext context, String text,
//       {int seconds = 3}) {
//     showToast(context, text, successColor, Icons.check_circle, seconds);
//   }
//
//   static void showErrorToast(BuildContext context, String text,
//       {int seconds = 3}) {
//     showToast(context, text, errorColor, Icons.cancel, seconds);
//   }
//
//   static void showInfoToast(BuildContext context, String text,
//       {int seconds = 3}) {
//     showToast(context, text, infoColor, Icons.info, seconds);
//   }
//
//   static void showWarningToast(BuildContext context, String text,
//       {int seconds = 3}) {
//     showToast(context, text, warningColor, Icons.warning_rounded, seconds);
//   }
//
//   static Future<void> showDialog({
//     required BuildContext context,
//     required String message,
//     required Color color,
//     required IconData icon,
//     String? description,
//     Function? confirmButton,
//     bool cancelButton = false,
//     String confirmButtonTitle = 'OK',
//     String cancelButtonTitle = 'Cancel',
//   }) async {
//     await showGeneralDialog(
//       context: context,
//       pageBuilder: (BuildContext buildContext, Animation<double> animation,
//           Animation<double> secondaryAnimation) {
//         return CustomDialog(
//           message: message,
//           icon: icon,
//           confirmButton: confirmButton ?? () => Navigator.of(context).pop(),
//           cancelButton: cancelButton,
//           confirmButtonTitle: confirmButtonTitle,
//           cancelButtonTitle: cancelButtonTitle,
//           description: description,
//           color: color,
//         );
//       },
//       barrierDismissible: true,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionDuration: const Duration(milliseconds: 200),
//     );
//   }
//
//   static Future<void> showSuccessDialog(BuildContext context, String message,
//       {String? description}) async {
//     await showDialog(
//       context: context,
//       message: message,
//       color: successColor,
//       icon: Icons.check_circle,
//       description: description,
//     );
//   }
//
//   static Future<void> showErrorDialog(BuildContext context, String message,
//       {String? description}) async {
//     await showDialog(
//       context: context,
//       message: message,
//       color: errorColor,
//       icon: Icons.cancel,
//       description: description,
//     );
//   }
//
//   static Future<void> showInfoDialog(BuildContext context, String message,
//       {String? description}) async {
//     await showDialog(
//       context: context,
//       message: message,
//       color: infoColor,
//       icon: Icons.info,
//       description: description,
//     );
//   }
//
//   static Future<void> showWarningDialog(BuildContext context, String message,
//       {String? description}) async {
//     await showDialog(
//       context: context,
//       message: message,
//       color: warningColor,
//       icon: Icons.warning_rounded,
//       description: description,
//     );
//   }
//
//   // progress methods
//   // layer index 1 is preserved for the progress indicator
//
//   static void showProgressOverlay(
//       {required BuildContext context,
//         required String text,
//         durationInSeconds = 65}) {
//     clearFocus(context);
//     showOverlay(
//         context: context,
//         layerIndex: _progressLayerIndex,
//         durationInSeconds: durationInSeconds,
//         widget: OverlayProgress(text));
//   }
//
//   static void hideProgressOverlay() {
//     hideOverlay(_progressLayerIndex);
//   }
//
//   static void clearFocus(BuildContext context) {
//     FocusScope.of(context).requestFocus(FocusNode());
//   }
// }
//
// // region Overlay Toast
//
// class OverlayToast extends StatelessWidget {
//   final String text;
//   final Color color;
//   final Color? backgroundColor;
//   final IconData iconData;
//
//   const OverlayToast(this.text, this.color, this.iconData,
//       {super.key, this.backgroundColor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
//       child: FullCol(
//         heights: "1* auto",
//         children: <Widget>[
//           Container(),
//           Material(
//             elevation: 10,
//             color: color.withOpacity(.5),
//             type: MaterialType.card,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(30)),
//               side: BorderSide.none,
//             ),
//             child: Row(
//               // widths: "auto 1*",
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Icon(
//                     iconData,
//                     color: Colors.white,
//                     size: 35,
//                   ),
//                 ),
//                 Expanded(
//                   child: Wrap(
//                     children: [
//                       Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Center(
//                             child: Text(text,
//                                 textAlign: TextAlign.start,
//                                 style: const TextStyle(
//                                     color: Colors.white, fontSize: 16)),
//                           )),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class OverlayProgress extends StatelessWidget {
//   final String text;
//
//   const OverlayProgress(this.text, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
//           child: Container(
//             color: Colors.black.withOpacity(0.6),
//           ),
//         ),
//         Center(
//           child: Material(
//             elevation: 2,
//             color: Colors.white,
//             type: MaterialType.card,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(50)),
//               side: BorderSide.none,
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(15),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   const CircularProgressIndicator(
//                     strokeWidth: 3,
//                   ),
//                   const SizedBox(
//                     width: 15,
//                   ),
//                   Text(
//                     text,
//                     style: const TextStyle(fontSize: 17),
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }