import 'package:flutter/material.dart';

class PaymentMethodsViewModel extends ChangeNotifier {
  final TextEditingController salePriceController = TextEditingController();

  double _calculatedCommission = 0.0;
  final double commissionRate = 0.01; // عمولة 1%

  double get calculatedCommission => _calculatedCommission;

  // حاسبة العمولة السريعة
  void calculateCommission(String value) {
    if (value.isEmpty) {
      _calculatedCommission = 0.0;
    } else {
      double price = double.tryParse(value) ?? 0.0;
      _calculatedCommission = price * commissionRate;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    salePriceController.dispose();
    super.dispose();
  }
}