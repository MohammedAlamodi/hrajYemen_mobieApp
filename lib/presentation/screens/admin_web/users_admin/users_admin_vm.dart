import 'package:flutter/material.dart';
import '../../../../model/admin_user_model.dart';
import '../../customer/home/home_repo.dart';

class UsersAdminVM extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool isLoading = false;
  List<AdminUserModel> users = [];
  List<AdminUserModel> filteredUsers = []; // للبحث

  final TextEditingController searchController = TextEditingController();

  UsersAdminVM() {
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    isLoading = true;
    notifyListeners();

    users = await _repo.fetchAdminUsers();
    filteredUsers = users;

    isLoading = false;
    notifyListeners();
  }

  // دالة البحث وتصفية المستخدمين
  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers = users;
    } else {
      filteredUsers = users.where((u) {
        final nameMatches = u.displayName.toLowerCase().contains(query.toLowerCase());
        final phoneMatches = u.phoneNumber?.contains(query) ?? false;
        final emailMatches = u.email?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return nameMatches || phoneMatches || emailMatches;
      }).toList();
    }
    notifyListeners();
  }

  // دالة مساعدة لتنسيق التاريخ القادم من السيرفر
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'غير معروف';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.split('T').first;
    }
  }
}