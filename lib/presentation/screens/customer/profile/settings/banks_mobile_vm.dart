import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../model/bank_account_model.dart';
import '../../../admin_web/banks_admin/banks_admin_repo.dart';
// استيراد المودل والسيرفيس

class BanksMobileVM extends ChangeNotifier {
  final BanksAdminRepo _repo = BanksAdminRepo();


  List<BankAccountModel> accounts = [];
  bool isServerLoading = false;

  BanksMobileVM() {
    loadData();
  }

  Future<void> loadData() async {
    // 1. جلب البيانات من التخزين المحلي فوراً وعرضها
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('cached_banks');

    if (cachedData != null && cachedData.isNotEmpty) {
      accounts = BankAccountModel.decode(cachedData);
      notifyListeners(); // عرض اللوكال فوراً
    }

    // 2. مزامنة مع السيرفر بالخلفية
    await fetchFromServer(prefs);
  }

  Future<void> fetchFromServer(SharedPreferences prefs) async {
    isServerLoading = true;
    notifyListeners();

    final freshAccounts = await _repo.fetchBanks();

    if (freshAccounts.isNotEmpty) {
      accounts = freshAccounts;
      // تحديث التخزين المحلي
      await prefs.setString('cached_banks', BankAccountModel.encode(accounts));
    }

    isServerLoading = false;
    notifyListeners();
  }
}