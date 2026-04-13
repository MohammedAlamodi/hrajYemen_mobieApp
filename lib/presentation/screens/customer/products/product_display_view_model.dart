import 'package:flutter/material.dart';

class ProductDisplayViewModel extends ChangeNotifier {
  // الحالة الافتراضية: true = شبكة (Grid)، false = قائمة (List)
  bool _isGridView = true;

  bool get isGridView => _isGridView;

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners(); // تحديث الواجهة عند التغيير
  }
}