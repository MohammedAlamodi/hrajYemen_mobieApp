import 'package:intl/intl.dart';


String getAmountWithoutDot(String? amount){

  if(amount != null && amount != 'null') {
    List a = amount.split('.');

    if (int.parse(a[1]) != 0) {
      return amount;
    } else {
      // تنسيق المبلغ باستخدام NumberFormat
      String formattedAmount = NumberFormat('#,##0').format(int.parse(a[0]));
      return formattedAmount;
    }
  }else{
    return '--';
  }
}