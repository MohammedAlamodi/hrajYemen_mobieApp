import 'package:flutter/material.dart';

import '../../../model/pay_commission_item_model.dart';
import '../../../model/user_model.dart';
import 'pay_commission_items_repo.dart';

class ProfileViewModel extends ChangeNotifier {
  final DynamicItemsRepository _itemsRepo = DynamicItemsRepository();
  List<DynamicItemModel> promotedItems = [];

  void loadPromotedItems() async {
    // هذه الدالة ذكية: تجيب من النت وتحدث الكاش، او تجيب من الكاش اذا النت مقطوع
    promotedItems = await _itemsRepo.getItems();
    notifyListeners();
  }
}