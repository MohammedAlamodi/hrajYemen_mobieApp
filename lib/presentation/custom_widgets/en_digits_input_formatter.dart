import 'package:flutter/services.dart';

/// تحويل الأرقام العربية (٠١٢...) والفارسية (۰۱۲...) إلى أرقام إنجليزية (012...).
String toEnglishDigits(String input) {
  const List<String> arabic = [
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'
  ];
  const List<String> persian = [
    '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'
  ];

  String out = input;
  for (int i = 0; i < 10; i++) {
    out = out.replaceAll(arabic[i], i.toString());
    out = out.replaceAll(persian[i], i.toString());
  }
  return out;
}

/// Formatter يُطبّق على حقول الأرقام (مثل السعر) ليحوّل أي رقم عربي/فارسي
/// يكتبه المستخدم إلى رقم إنجليزي مباشرةً أثناء الكتابة.
class EnglishDigitsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String converted = toEnglishDigits(newValue.text);
    if (converted == newValue.text) return newValue;
    // الطول لا يتغيّر (استبدال حرف بحرف) فيبقى موضع المؤشّر صالحاً
    return TextEditingValue(
      text: converted,
      selection: newValue.selection,
    );
  }
}
