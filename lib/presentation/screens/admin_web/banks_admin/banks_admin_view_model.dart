import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ye_hraj/presentation/screens/admin_web/banks_admin/banks_admin_repo.dart';

import '../../../../model/bank_account_model.dart';
// استيراد المودل والسيرفيس

class BanksAdminVM extends ChangeNotifier {
  final BanksAdminRepo _repo = BanksAdminRepo();

  List<BankAccountModel> accounts = [];
  bool isLoading = false;
  bool isActionLoading = false; // يستخدم أثناء الحفظ لتغيير الزر إلى لودينج

  BanksAdminVM() {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    isLoading = true;
    notifyListeners();

    accounts = await _repo.fetchBanks();

    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveAccount(BuildContext context, {BankAccountModel? bank, required String name, required String accountNumber, XFile? image}) async {
    isActionLoading = true;
    notifyListeners();

    bool success;
    if (bank == null) {
      // إضافة جديد
      success = await _repo.createBank(name: name, accountNumber: accountNumber, image: image);
    } else {
      // تعديل
      success = await _repo.updateBank(bank.id!, name, accountNumber, image);
    }

    if (success) {
      await loadAccounts(); // تحديث الجدول
    }

    isActionLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> deleteAccount(int id) async {
    // يفضل إضافة Confirmation Dialog قبل الحذف في الـ UI
    bool success = await _repo.deleteBank(id);
    if (success) {
      await loadAccounts();
    }
  }
}