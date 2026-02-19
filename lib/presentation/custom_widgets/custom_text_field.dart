import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../configurations/resources/app_colors.dart';
import '../../configurations/resources/font_manager.dart';
import 'custom_text.dart';

class CustomTextField extends StatefulWidget {
  final String? hint;
  final String? labelText;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? suffixTextColor;
  final String? errorText;
  final String? suffixText;
  final Function(String?)? onSaved;
  final ValueChanged<String>? onChange;
  final String? Function(String? val)? validator;
  final Function(String?)? onFileSubmitted;
  final bool? enabled;
  final bool? availableArabic;
  final TextInputType? type;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final String? title;
  final String? fontFamily;

  final bool? isPhoneNumber;
  final bool? obscureText;
  final double borderRadius;
  final int? linesNumber;

  // final int? maxLength;
  final EdgeInsetsGeometry contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign? textAlign;
  final Color? fillColor;
  final Color? hintColor;
  final double? hintFontSize;
  final bool? dynamicHeight;
  final bool? readOnly;
  final bool enableBarcode; // Add this property
  final Function(String)? onBarcodeScanned; // Add this property

  const CustomTextField({
    super.key,
    this.errorText,
    this.suffixTextColor,
    this.suffixText,
    this.labelText,
    this.title,
    this.dynamicHeight = false,
    this.focusedBorderColor = Colors.black,
    this.enabledBorderColor = Colors.grey,
    this.type,
    this.hint,
    this.onSaved,
    this.fontFamily,
    this.enabled = true,
    this.validator,
    this.onChange,
    this.onFileSubmitted,
    this.availableArabic = true,
    this.controller,
    this.initialValue,
    this.isPhoneNumber = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 8,
    this.linesNumber = 1,
    // this.maxLength,
    this.fillColor = Colors.white,
    this.hintColor = Colors.grey,
    this.hintFontSize,
    this.textAlign,
    this.contentPadding =
        const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
    this.textInputAction,
    this.readOnly,
    this.enableBarcode = false,
    this.onBarcodeScanned,
    // this.textDirection:TextDirection.ltr,
  });

  @override
  State<CustomTextField> createState() => _CustomFieldsWidgetState();
}

class _CustomFieldsWidgetState extends State<CustomTextField>{
  // bool isBarcodeScannerVisible = false; // To control barcode scanner visibility
  // MobileScannerController?
  //     _scannerController; // Controller for the MobileScanner
  // String? lastScannedCode;
  // DateTime? lastScanTime;
  // late PartnersViewModel partnersViewModel;
  // bool _isFlashing = false; // متغير للتحكم في الوميض


  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.enableBarcode) {
  //     _scannerController = MobileScannerController(
  //       facing: CameraFacing.back,
  //       torchEnabled: false,
  //     );
  //    // CProvider
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          widget.title != null ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                title: widget.title ?? '',
                textAlign: TextAlign.start,
                size: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .fontSize!,
              ),
            ],
          ) : SizedBox(),
          SizedBox(height: 5,),
          SizedBox(
            // height: !widget.dynamicHeight! ? AppConstants.heightButtonStandard : null,
            child: Directionality(
              textDirection: Localizations.localeOf(context).languageCode == 'en'
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: TextFormField(
                textInputAction: widget.textInputAction,
                onFieldSubmitted: widget.onFileSubmitted ?? (v) {},
                obscureText: widget.obscureText!,
                maxLines: widget.linesNumber,
                enabled: widget.enabled,

                readOnly: widget.readOnly ?? false,
                // maxLength: widget.maxLength,
                textAlign: widget.textAlign != null
                    ? widget.textAlign!
                    : Localizations.localeOf(context).languageCode == 'en'
                        ? TextAlign.left
                        : TextAlign.right,

                validator: widget.validator,
                initialValue: widget.initialValue,
                onSaved: (val) {
                  widget.onSaved!(val);
                },
                // cursorColor: Colors.black,
                cursorColor: AppColors.current.primary,
                keyboardType: widget.type,
                onChanged: (val) {
                  try {
                    widget.onChange!(val);
                  } catch (e) {}
                },
                controller: widget.controller,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                    color: widget.enabled!
                        ? Colors.black
                        : AppColors.current.primary,
                    fontWeight: FontWeight.normal,
                    fontFamily: widget.fontFamily ?? FontConstants.fontFamily),
                autocorrect: false,
                inputFormatters: widget.availableArabic!
                    ? null
                    : widget.isPhoneNumber!
                        ? <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                          ]
                        : <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-Z-0-9@. ]")),
                          ],
                decoration: InputDecoration(
                  prefixIcon: widget.prefixIcon,
                  // suffixIcon: widget.suffixIcon,

                  suffixText: widget.suffixText,
                  suffixStyle: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                    color: widget.suffixTextColor,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.enableBarcode)
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () async {
                            // _isFlashing = false;
                            // _openScannerDialog(context);
                            final code = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setSte) {
                                    return Dialog(
                                      // backgroundColor:_isFlashing? Colors.green : Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // const Padding(
                                            //   padding: EdgeInsets.all(16.0),
                                            //   child: CustomText(
                                            //     title: "Scan",
                                            //     size: 30,
                                            //     fontWeight: FontWeight.w900,
                                            //   ),
                                            // ),
                                            // SizedBox(
                                            //   width: widthOfScreen(context) * 0.8,
                                            //   height: widthOfScreen(context) * 0.8,
                                            //   child: ClipRRect(
                                            //     borderRadius:
                                            //     BorderRadius.circular(20),
                                            //     child: MobileScanner(
                                            //       controller: _scannerController!,
                                            //       // scanWindowUpdateThreshold: 1,
                                            //       onDetect: (capture) {
                                            //         final code = capture.barcodes.firstOrNull?.rawValue;
                                            //
                                            //         if (code != null && _canScanAgain(code)) {
                                            //           setSte(() {
                                            //             lastScannedCode = code;
                                            //             lastScanTime = DateTime.now();
                                            //             _triggerFlash(setSte);
                                            //           });
                                            //           widget.onBarcodeScanned!(code);
                                            //           // _isFlashing = false;
                                            //         }
                                            //
                                            //       },
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                );
                              },
                            );

                            if (code != null) {
                              debugPrint('Barcode found! $code');
                              widget.controller?.text = code;
                            // _triggerFlash();
                              widget.onBarcodeScanned?.call(code);

                            }
                          },
                        ),
                      if (widget.suffixIcon != null) widget.suffixIcon!,
                    ],
                  ),
                  labelText: widget.labelText,
                  errorText: widget.errorText,
                  labelStyle: TextStyle(
                      fontSize: widget.hintFontSize ??
                          Theme.of(context).textTheme.bodySmall!.fontSize! - 3,
                      fontFamily: FontConstants.fontFamily),
                  border: const OutlineInputBorder(),
                  hintText: widget.hint,

                  filled: true,
                  hintStyle: TextStyle(
                      fontSize: widget.hintFontSize ??
                          Theme.of(context).textTheme.bodySmall!.fontSize! - 3,
                      color: widget.hintColor!,
                      fontFamily: FontConstants.fontFamily
                  ),
                  contentPadding: widget.contentPadding,
                  fillColor: !widget.enabled!
                      ? AppColors.current.warning.withOpacity(.2)
                      : widget.fillColor!,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: BorderSide(
                        color: !widget.enabled!
                            ? AppColors.current.error
                            : widget.enabledBorderColor!,
                        width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius + 3),
                    borderSide: BorderSide(
                      color: AppColors.current.primary,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: BorderSide(
                      color: widget.enabledBorderColor!,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5,)
          // if (isBarcodeScannerVisible)
          //   Positioned.fill(
          //     // Use Positioned.fill to cover the screen
          //     child: MobileScanner(
          //       controller: MobileScannerController(
          //         facing: CameraFacing.back, // Use the back camera by default
          //         torchEnabled: false, // Start with the torch off
          //       ),
          //       onDetect: (capture) {
          //         final code = capture.barcodes.firstOrNull?.rawValue;
          //         if (code != null) {
          //           debugPrint('Barcode found! $code');
          //           widget.controller?.text = code;
          //           widget.onBarcodeScanned?.call(code);
          //           setState(() {
          //             isBarcodeScannerVisible = false;
          //           });
          //         }
          //       },
          //     ),
          //   ),
        ],
      ),
    );
  }

  // دالة لفتح دايلوج المسح الضوئي
//   void _openScannerDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // منع إغلاق الدايلوج عند الضغط خارج النافذة
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('المسح الضوئي'),
//               content: Stack(
//                 children: [
//                   const MobileScanner(
//                     // onDetect: (barcode, args) {
//                     //   final String? code = barcode.rawValue;
//                     //   if (code != null) {
//                     //     setState(() {
//                     //       _controller.text = code; // تعيين الكود في TextField
//                     //       _triggerFlash(setState); // تفعيل الوميض
//                     //     });
//                     //   }
//                     // },
//                   ),
//                   if (_isFlashing)
//                     Container(
//                       color: Colors.green.withOpacity(0.5), // وميض أخضر
//                     ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // إغلاق الدايلوج
//                   },
//                   child: const Text('إغلاق'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // دالة لتفعيل الوميض الأخضر
//   void _triggerFlash(StateSetter setState) {
//     setState(() {
//       _isFlashing = true; // عرض الوميض
//     });
//
//     // إخفاء الوميض بعد 300 ميلي ثانية
//     Future.delayed(const Duration(milliseconds: 500), () {
//       setState(() {
//         _isFlashing = false;
//       });
//     });
//   }
//
//   bool _canScanAgain(String code) {
//     if (lastScannedCode == code) {
//       if (lastScanTime != null &&
//           DateTime.now().difference(lastScanTime!).inSeconds < 4) {
//         return false;
//       }else{
//         return true;
//       }
//     }
//     return true;
//   }
}






