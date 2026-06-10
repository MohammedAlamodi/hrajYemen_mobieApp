import 'package:flutter/material.dart';
import '../../../../configurations/data/api_services.dart';
import '../../../../model/admin_user_model.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../customer/home/home_repo.dart';

class UsersAdminVM extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool isLoading = false;
  bool isActionLoading = false; //الة التحميل لزر الحظر

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

  // 🔥 دالة حظر / فك حظر المستخدم
  Future<void> toggleUserBlockStatus(BuildContext context, String userId) async {
    isActionLoading = true;
    notifyListeners();

    try {
      await ApiService().getToken();

      final response = await ApiService().dio.put(
        'api/Admin/ToggleUserBlocked/$userId/toggle-status-blocked',
      );

      // التأكد من نجاح الطلب ووجود بيانات في الرد
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        // قراءة القيم من الرد القادم من السيرفر
        final bool isBlockedFromServer = responseData['isBlocked'] ?? false;
        final String serverMessage = responseData['message'] ?? 'تم تغيير الحالة بنجاح';

        // تحديث حالة المستخدم محلياً لكي ينعكس على الواجهة فوراً (بناءً على تأكيد السيرفر)
        final userIndex = users.indexWhere((u) => u.id == userId);
        if (userIndex != -1) {
          users[userIndex].isBlocked = isBlockedFromServer;

          final filteredIndex = filteredUsers.indexWhere((u) => u.id == userId);
          if (filteredIndex != -1) {
            filteredUsers[filteredIndex].isBlocked = isBlockedFromServer;
          }
        }

        // عرض رسالة الـ SnackBar بالرسالة القادمة من السيرفر
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(title: serverMessage, color: Colors.white, size: 14),
              backgroundColor: isBlockedFromServer ? Colors.red : Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error toggling user block status: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تغيير حالة المستخدم'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  // دالة مساعدة لتنسيق التاريخ
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