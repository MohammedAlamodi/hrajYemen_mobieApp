import 'package:flutter/material.dart';
import '../../../../model/admin_stats_model.dart';
import '../../customer/home/home_repo.dart';

class DashboardAdminVM extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool isLoading = false;
  AdminStatsModel? stats;
  DateTime? startDate;
  DateTime? endDate;


  DashboardAdminVM() {
    fetchStats();
  }

  // دالة استقبال التاريخ من الشاشة
  void filterByDate(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    fetchStats(); // إعادة جلب البيانات
  }

  // دالة إلغاء الفلتر
  void clearDateFilter() {
    startDate = null;
    endDate = null;
    fetchStats(); // إعادة جلب البيانات بدون تاريخ
  }

  Future<void> fetchStats() async {
    isLoading = true;
    notifyListeners();

    debugPrint('Fetching stats with date filter: ${startDate != null && endDate != null ? 'From $startDate to $endDate' : 'No date filter'}');

    stats = await _repo.fetchAdminStats(
      startDate: startDate,
      endDate: endDate,
    );

    isLoading = false;
    notifyListeners();
  }
}