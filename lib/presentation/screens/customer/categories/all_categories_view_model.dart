import 'package:flutter/material.dart';
import '../../../../model/category_model.dart';
import '../home/home_repo.dart';

class AllCategoriesViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];
  bool _isLoading = true;

  List<CategoryModel> get categories => _filteredCategories;
  bool get isLoading => _isLoading;

  // جلب الأقسام
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // هنا نجلب البيانات من السيرفر (محاكاة)
      _allCategories = await _repo.fetchCategories(); // تأكد أن الـ Repo يرجع ألوان مختلفة
      _filteredCategories = _allCategories;
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // منطق البحث
  void searchCategories(String query) {
    if (query.isEmpty) {
      _filteredCategories = _allCategories;
    } else {
      _filteredCategories = _allCategories
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}