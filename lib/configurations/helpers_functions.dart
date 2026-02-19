// ignore_for_file: avoid_print, use_build_context_synchronously, non_constant_identifier_names, unused_local_variable, unnecessary_null_comparison, prefer_if_null_operators, empty_catches

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'resources/app_colors.dart';

String getCurrency(String cry){

  var ccc = cry == '0'
      ? "\$"
      : cry == '1'
      ? 'SR'
      : cry == '2'
      ? 'YR'
      : cry == '3'
      ? 'GBP'
      : cry == '4'
      ? 'AED'
      : "-";

  return ccc;

}

// Future printBill(int invoiceId, BuildContext context, int index_sunmi) async {
//   ShiftingViewModel shiftingViewModel = Provider.of<ShiftingViewModel>(context, listen: false);
//
//   // final hiveAllSales = Provider.of<Provider_AllSales>(context, listen: false);
//
//  debugPrint("invoiceId ======> ${invoiceId.toString()}");
//
//   Uri uri = Uri.parse('${EndPointsStrings.baseUrl}api/Incoice/SelleInfo/$invoiceId');
//
//  debugPrint('************************** uri $uri');
//
//   http.Response response = await http.get(uri).then((value) {
//     return value;
//   });
//   //
//
//   if (response.statusCode == 200) {
//     //
//    debugPrint('--------------------------------- 777777777777 ');
//
//    debugPrint('***************************// value ${jsonDecode(response.body)}');
//
//     var responseBody = jsonDecode(response.body);
//    debugPrint('--------------------------------- 8888888888888 ');
//
//     InvoiceData invoiceData = InvoiceData.fromJson(responseBody);
//
//     // String dateNow = DateFormat.yMd().add_jm().toString();
//
//     String cashierName = await getString(AppStrings.fullNameKey, '');
//     String cashierDevice = shiftingViewModel.deviceName;
//     // double price = 20;
//
//     List listInvoice = [];
//
//     List extras = [];
//
//     for (int i = 0; i < invoiceData.sellProducts!.length; i++) {
//       listInvoice.add(
//         InvoiceUtilities(
//           productName: invoiceData.sellProducts![i].productName.toString(),
//           unitName: invoiceData.sellProducts![i].unityProduct.toString(),
//           finalCost: double.parse(invoiceData.sellProducts![i].total!),
//           opUnitPrice: double.parse(invoiceData.sellProducts![i].priceBuy!),
//           productQuantity: invoiceData.sellProducts![i].qntProduct!,
//           //
//           numberInvoice: invoiceData.selle?.numberSelle.toString(),
//           time: '${invoiceData.selle?.dateRelease}  ${invoiceData.selle?.timeRelease}',
//           the_name: 'اسم الكاشير ',
//           divice_name: cashierName,
//
//           serial_number: '${invoiceData.sellProducts![i].serial_number}',
//
//           extras: invoiceData.sellProducts![i].extras!,
//
//           unity_product_quantity: invoiceData.sellProducts![i].unity_product_quantity!,
//         ),
//       );
//
//       //
//
//       for (int indx = 0; indx < invoiceData.sellProducts![i].extras!.length; indx++) {
//         extras.add(invoiceData.sellProducts![i].extras![indx]);
//       }
//     }
//
//     List<PaymentWays> paymentList = [];
//
//     if (invoiceData.sellPayments!.isNotEmpty) {
//       for (int i = 0; i < invoiceData.sellPayments!.length; i++) {
//         paymentList.add(
//           PaymentWays(paymentValue: invoiceData.sellPayments![i].amount!, paymentType: invoiceData.sellPayments![i].name!),
//         );
//       }
//     }
//
//     //debugPrint("cashierName ${invoiceData.sellProducts![0].extras!}");
//    debugPrint("cashierDevice4444444444444 $extras");
//    debugPrint("LOGO: ${invoiceData.brancheSetting?.icon}");
//     final Newww = Provider.of<BluetoothPrintersProvider>(context, listen: false);
//
//     try {
//       if (Newww.Data[index_sunmi]['other_print'] == true) {
//        debugPrint('#####################################################');
//        debugPrint('----sunmi  ${Newww.Data[index_sunmi]['other_print']}');
//
//         prepareInvoice(
//           companyLogoImage: invoiceData.branche?.logo,
//           companyName: invoiceData.branche?.name ?? '',
//           companyAddress: invoiceData.branche?.adresse ?? '',
//           taxNumber: invoiceData.branche?.taxNumber ?? '00',
//           numberInvoice: invoiceData.selle?.numberSelle.toString(),
//           releaseDate: '${invoiceData.selle?.dateRelease} ${invoiceData.selle?.timeRelease}',
//           supplyDate: '${invoiceData.selle?.dateSupply} ${invoiceData.selle?.timeSupply}',
//           invoiceType: invoiceData.selle?.typeInvoice.toString() == 'texed' ? 'فاتورة ضريبية' : 'فاتورة ضريبية مبسطة',
//           customerName: invoiceData.customerBranch?.name,
//           // amountWithoutTax: invoiceData.selle?.totalNoTax.toString(),
//           amountWithoutTax: invoiceData.selle?.totalNoTax.toString() == '0.00' ? '00.000' : invoiceData.selle?.totalNoTax.toString(),
//           amountWitTax: invoiceData.selle?.totalWithTax.toString(),
//           discountValue: invoiceData.selle?.discount.toString() == '0.00' ? '00.000' : invoiceData.selle?.discount.toString(),
//           amountAfterDiscount: invoiceData.selle?.totalAfterDiscount.toString(),
//           taxAdded: invoiceData.selle?.tax.toString(),
//           totalAmount: invoiceData.selle?.total.toString(),
//           paidUp: invoiceData.paid.toString(),
//           residualValue: invoiceData.rest.toString() == '0' ? '00.00' : invoiceData.rest.toString(),
//           cashierCustomerName: cashierName,
//           cashierDevice: cashierDevice,
//           context: context,
//           customerVat: invoiceData.customerBranch?.vatNumber ?? '',
//           typePayment: 'اجل',
//           customerAddress: invoiceData.customerBranch?.adress ?? '',
//           companyNumber: invoiceData.brancheSetting?.phone ?? '',
//           qrCodeString: invoiceData.tLV ?? '',
//           paymentList: paymentList,
//           listInvoice: listInvoice,
//         );
//       }
//       //
//     } catch (e) {}
//     response.statusCode == 200 ? Newww.printBill_statusCode = true : Newww.printBill_statusCode = false;
//
//    debugPrint('-------------------------33333333333333333333333333');
//
//     // Newww.list_item = listInvoice;
//
//     Newww.Share_list_item = listInvoice;
//
//    debugPrint('$invoiceId');
//
//     //--------------->>>>>
//
//     Newww.Send_D_Bill = Bills_BL_IP(
//       invoiceData.branche?.logo,
//       invoiceData.branche?.name ?? '',
//       invoiceData.branche?.adresse ?? '',
//       'متزامن',
//       invoiceData.branche?.taxNumber ?? '00',
//       invoiceData.brancheSetting?.phone ?? '',
//
//       //
//       [],
//       Newww.Share_list_item, // الاصناف
//       //
//       invoiceData.selle?.numberSelle.toString(),
//       '${invoiceData.selle?.dateRelease} ${invoiceData.selle?.timeRelease}',
//       '',
//       invoiceData.selle?.typeInvoice.toString() == 'texed' ? 'فاتورة ضريبية' : 'فاتورة ضريبية مبسطة',
//       invoiceData.customerBranch?.name,
//       invoiceData.selle?.totalNoTax.toString() == '0.00' ? '00.00' : invoiceData.selle?.totalNoTax.toString(),
//       invoiceData.selle?.totalWithTax.toString(),
//       invoiceData.selle?.discount.toString() == '0.00' ? '00.00' : invoiceData.selle?.discount.toString(),
//       invoiceData.selle?.totalAfterDiscount.toString(),
//       invoiceData.selle?.tax.toString(),
//       invoiceData.selle?.total.toString(),
//       "0.00",
//       invoiceData.paid.toString(),
//       invoiceData.rest.toString() == '0' ? '00.00' : invoiceData.rest.toString(),
//       invoiceData.tLV ?? '',
//       cashierName,
//       cashierDevice,
//       paymentList ?? '',
//       extras,
//       invoiceData.selle!.table.toString(),
//       [],
//     );
//     //
//   } else {
//     OverlayHelper.showErrorToast(context, S.of(context)!.errorInPrintBill);
//     // return null;
//   }
// }

emp() {}

// showCustomDialog(
//   BuildContext context, {
//   String? popTitle,
//   bool? withTwoButton = false,
//   bool? withOneButton = false,
//   bool? loadingOneButton = false,
//   bool? closeButton = true,
//   String? popBody,
//   double? popHeight,
//   Function()? primaryButtonAction,
//   Function()? secondaryButtonAction,
//   final PopType? popType,
//   final String? titleOfOneButton,
//   final String? titleOfTwoButton,
//   final bool? oneButtonOutLine = false,
//   final bool? twoButtonOutLine = false,
//   final Color? oneButtonColor,
//   final Color? twoButtonColor,
//   final Color? oneButtonTextColor,
//   final Color? twoButtonTextColor,
// }) {
//   return showDialog(
//     context: context,
//     builder: (context) {
//       return CustomPop(
//         popBody: popBody,
//         popTitle: popTitle,
//         popType: popType ?? PopType.truePop,
//         closeButton: closeButton!,
//         popHeight: popHeight,
//         oneButtonAction: primaryButtonAction ?? () {},
//         withOneButton: withOneButton!,
//         oneButtonTextColor: oneButtonTextColor,
//         oneButtonOutLine: oneButtonOutLine!,
//         oneButtonColor: oneButtonColor,
//         titleOfOneButton: titleOfOneButton,
//         loadingOneButton: loadingOneButton!,
//         secondaryButtonAction: secondaryButtonAction ?? () {},
//         withTwoButton: withTwoButton!,
//         twoButtonTextColor: twoButtonTextColor,
//         twoButtonOutLine: twoButtonOutLine!,
//         twoButtonColor: twoButtonColor,
//         titleOfTwoButton: titleOfTwoButton,
//       );
//     },
//   );
// }

bool validateEmail(String value) {
  String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  RegExp regex = RegExp(pattern);
  return (!regex.hasMatch(value)) ? false : true;
}

double heightOfScreen(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  return screenHeight;
}

bool isPortrait(BuildContext context) {
  return MediaQuery.of(context).orientation == Orientation.portrait;
}

bool isTablet(BuildContext context) {
  return heightOfScreen(context) >= 600 && widthOfScreen(context) >= 600;
}

double widthOfScreen(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  return screenWidth;
}

/// this function to remove one key from local storage
removeDataFromStorage(String key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

/// this function will remove all data from local storage
removeAllDataFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Widget divider({double? marginHorizontal, double? marginVertical}) {
  return Container(
    margin: EdgeInsets.symmetric(
        horizontal: marginHorizontal ?? 0, vertical: marginVertical ?? 0),
    height: 0.2,
    color: AppColors.current.grey,
  );
}

double percentHeightAndWidthOfScreen(BuildContext context) {
  double percentHeight =
      MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
  return percentHeight;
}

formatDate(String date) {
  DateTime myDate = DateTime.parse(date);
  return DateFormat('yyyy/MM/dd').format(myDate);
}

Future<bool> isConnectedToInternet() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } on SocketException catch (_) {
    return false;
  }
}

// showCustomBottomSheet(
//     {BuildContext? context,
//     final String? title,
//     final bool? withTwoButtons,
//     final Widget? bodyOfSheet,
//     final double? bottomSheetHeight,
//     final bool? withOneButtons = false,
//     final bool? loadingTwoButton = false,
//     final bool? isDismissible}) {
//   return showMaterialModalBottomSheet(
//     isDismissible: isDismissible ?? true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(20.0),
//     ),
//     context: context!,
//     builder: (context) {
//       return WillPopScope(
//         onWillPop: () async {
//           return true;
//         },
//         child: CustomBottomSheet(
//           bottomSheetHeight: bottomSheetHeight,
//           title: title,
//           bodyOfSheet: bodyOfSheet,
//         ),
//       );
//     },
//   );
// }

Future<void> saveFileToAppDirectory(List<int> bytes, String fileName) async {
  try {
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory?.path}/$fileName';
    final file = File(filePath);

    await file.writeAsBytes(Uint8List.fromList(bytes));
    debugPrint("File saved at $filePath");
  } catch (e) {
    debugPrint("Error occurred while saving the file: $e");
  }
}

// Future<void> saveFileToUserChosenLocation(
//     List<int> bytes, String fileName) async {
//   try {
//     debugPrint("saveFileToUserChosenLocation");
//
//     // Request storage permission
//
//     if (!(await requestStoragePermissions())) {
//       debugPrint("Storage permission denied");
//       return;
//     }
//
//     // For Android 10 and above, we'll use SAF
//     if (Platform.isAndroid) {
//       Uint8List uint8list = Uint8List.fromList(bytes);
//       String? result = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save Excel File',
//         fileName: fileName,
//         bytes: uint8list,
//         type: FileType.custom,
//         allowedExtensions: ['xlsx'],
//       );
//
//       if (result != null) {
//         final file = File(result);
//         await file.writeAsBytes(bytes);
//         debugPrint("File saved at ${file.path}");
//       } else {
//         debugPrint("User canceled the file save dialog.");
//       }
//     } else {
//       // For iOS or older Android versions
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName');
//       await file.writeAsBytes(bytes);
//       debugPrint("File saved at ${file.path}");
//     }
//   } catch (e) {
//     debugPrint("Error occurred while saving the file: $e");
//   }
// }
//
// Future<bool> requestStoragePermissions() async {
//   final status = await Permission.storage.request();
//   if (status.isGranted) {
//     debugPrint("Permission granted.");
//     return true;
//   } else {
//     debugPrint("Permission denied.");
//     return false;
//   }
// }
