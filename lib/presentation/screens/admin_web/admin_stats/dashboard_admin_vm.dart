import 'package:flutter/material.dart';
import '../../../../model/admin_stats_model.dart';
import '../../customer/home/home_repo.dart';

class DashboardAdminVM extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool isLoading = false;
  AdminStatsModel? stats;

  DashboardAdminVM() {
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading = true;
    notifyListeners();

    stats = await _repo.fetchAdminStats();

    isLoading = false;
    notifyListeners();
  }
}