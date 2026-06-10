import 'package:flutter/material.dart';
import '../../../../configurations/data/end_points_manager.dart';
import '../../../../configurations/user_preferences.dart';
import '../../../../model/product_model.dart';
import '../../customer/home/home_repo.dart';

class AdsAdminVM extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool isLoading = false;
  bool isLoadingMore = false;
  bool isDetailsLoading = false;
  bool isActionLoading = false;

  List<ProductModel> products = [];
  int currentPage = 1;
  bool hasMoreData = true;

  String baseUrl = EndPointsStrings.baseUrl;

  final TextEditingController searchIdController = TextEditingController();

  // متغيرات الفلترة
  String? activeUserIdFilter;
  String? activeStatusFilter;
  int? searchAdId; // للبحث برقم الإعلان

  AdsAdminVM({String? initialUserId, String? initialStatus}) {
    activeUserIdFilter = initialUserId;
    activeStatusFilter = initialStatus;
    _init();
  }

  Future<void> _init() async {
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    await fetchInitialProducts();
  }

  // 🔥 دالة البحث برقم الإعلان
  void searchByAdId(String id) {
    int? parsedId = int.tryParse(id);
    if (parsedId != null) {
      searchAdId = parsedId;
      fetchInitialProducts();
    }
  }

  // 🔥 مسح البحث
  void clearSearch() {
    searchIdController.clear();
    searchAdId = null;
    fetchInitialProducts();
  }

  // 🔥 تغيير فلتر الحالة (النشطة، المنتهية، المحظورة)
  void changeStatusFilter(String? newStatus) {
    if (activeStatusFilter == newStatus) return; // إذا ضغط على نفس الزر لا تفعل شيء
    activeStatusFilter = newStatus;
    fetchInitialProducts();
  }

  // 🔥 إزالة فلتر المستخدم المخصص
  void clearUserFilter() {
    activeUserIdFilter = null;
    fetchInitialProducts();
  }

  String getFullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http')) return path;
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl$cleanPath';
  }

  // ==================== جلب الإعلانات ====================

  // 🔥 دالة مساعدة لترجمة الفلتر النصي إلى (True/False)
  void _applyStatusLogic(void Function(bool? isActiveParam, bool? isBlockedParam) onApply) {
    bool? isActiveParam;
    bool? isBlockedParam;

    if (activeStatusFilter == 'active') {
      isActiveParam = true;   // يجب أن يكون نشط
      isBlockedParam = false; // ويجب ألا يكون محظوراً
    } else if (activeStatusFilter == 'expired') {
      isActiveParam = false;  // منتهي
      // لا يهمنا إن كان محظوراً أو لا طالما هو منتهي
    } else if (activeStatusFilter == 'blocked') {
      isBlockedParam = true;  // محظور
      // لا يهمنا إن كان نشط أو منتهي طالما هو محظور
    }

    onApply(isActiveParam, isBlockedParam);
  }

  Future<void> fetchInitialProducts() async {
    isLoading = true;
    currentPage = 1;
    hasMoreData = true;
    notifyListeners();

    // نترجم الفلتر ثم نستدعي الـ Repo
    _applyStatusLogic((isActiveParam, isBlockedParam) async {
      products = await _repo.fetchProducts(
        page: currentPage,
        limit: 12,
        adId: searchAdId,
        userId: activeUserIdFilter,
        isActive: isActiveParam,    // 👈 نمرر قيمة النشط/المنتهي
        isBlocked: isBlockedParam,  // 👈 نمرر قيمة الحظر
      );

      if (products.length < 12) {
        hasMoreData = false;
      }

      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore || !hasMoreData) return;

    isLoadingMore = true;
    notifyListeners();

    currentPage++;

    // نترجم الفلتر ثم نستدعي الـ Repo
    _applyStatusLogic((isActiveParam, isBlockedParam) async {
      final newProducts = await _repo.fetchProducts(
        page: currentPage,
        limit: 12,
        adId: searchAdId,
        userId: activeUserIdFilter,
        isActive: isActiveParam,    // 👈 نمرر قيمة النشط/المنتهي
        isBlocked: isBlockedParam,  // 👈 نمرر قيمة الحظر
      );

      if (newProducts.isEmpty) {
        hasMoreData = false;
      } else {
        products.addAll(newProducts);
      }

      isLoadingMore = false;
      notifyListeners();
    });
  }

  // ==================== تفاصيل الإعلان وحالته ====================

  Future<ProductModel?> getProductDetails(int productId) async {
    isDetailsLoading = true;
    notifyListeners();

    final details = await _repo.fetchProductDetails(productId);

    isDetailsLoading = false;
    notifyListeners();
    return details;
  }

// ==================== تفاصيل الإعلان وحالته ====================

  Future<void> blockOrUnblockAd(BuildContext context, int productId) async {
    isActionLoading = true;
    notifyListeners();

    // 👈 استدعاء الدالة الحقيقية بالمسار الجديد
    bool isSuccess = await _repo.toggleBlockStatus(productId);

    isActionLoading = false;
    notifyListeners();

    if (isSuccess && context.mounted) {
      Navigator.pop(context); // إغلاق نافذة التفاصيل
      await fetchInitialProducts(); // تحديث القائمة فوراً من السيرفر

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث حالة حظر المنتج بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء محاولة حظر المنتج'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}