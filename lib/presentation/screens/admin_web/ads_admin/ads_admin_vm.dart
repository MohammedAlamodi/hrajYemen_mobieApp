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

  AdsAdminVM() {
    _init();
  }

  Future<void> _init() async {
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    await fetchInitialProducts();
  }

  String getFullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http')) return path;
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl$cleanPath';
  }

  // ==================== جلب الإعلانات ====================

  Future<void> fetchInitialProducts() async {
    isLoading = true;
    currentPage = 1;
    hasMoreData = true;
    notifyListeners();

    // جلب أول 12 إعلان للوحة التحكم
    products = await _repo.fetchProducts(page: currentPage, limit: 12);

    if (products.length < 12) {
      hasMoreData = false;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore || !hasMoreData) return;

    isLoadingMore = true;
    notifyListeners();

    currentPage++;
    final newProducts = await _repo.fetchProducts(page: currentPage, limit: 12);

    if (newProducts.isEmpty) {
      hasMoreData = false;
    } else {
      products.addAll(newProducts);
    }

    isLoadingMore = false;
    notifyListeners();
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

  // Future<void> toggleAdStatus(BuildContext context, ProductModel product) async {
  //   isActionLoading = true;
  //   notifyListeners();
  //
  //   // 1. تحديد الحالة الجديدة (عكس الحالة الحالية)
  //   // ملاحظة: تأكد أن المتغير في السيرفر اسمه isActive، أو عدله لـ status حسب المودل الخاص بكم
  //   final newStatus = !(product.isActive ?? true);
  //
  //   // 2. تحويل المنتج الحالي بالكامل إلى Map
  //   Map<String, dynamic> productData = product.toJson();
  //
  //   // 3. تعديل الحالة الجديدة داخل الـ Map
  //   productData['isActive'] = newStatus; // 👈 غير اسم 'isActive' إذا كان السيرفر يستخدم اسماً آخر
  //
  //   // productData.remove('images');
  //
  //   // 4. إرسال المنتج بالكامل للسيرفر عبر الـ Repo الجديد
  //   bool isSuccess = await _repo.updateProduct(
  //     productId: product.id ?? 0,
  //     data: productData,
  //   );
  //
  //   isActionLoading = false;
  //   notifyListeners();
  //
  //   // 5. التعامل مع النتيجة
  //   if (isSuccess && context.mounted) {
  //     Navigator.pop(context); // إغلاق نافذة التفاصيل
  //     await fetchInitialProducts(); // تحديث القائمة لإظهار الحالة الجديدة
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(newStatus ? 'تم تفعيل الإعلان بنجاح' : 'تم إيقاف الإعلان بنجاح'),
  //         backgroundColor: newStatus ? Colors.green : Colors.orange,
  //       ),
  //     );
  //   } else if (context.mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('حدث خطأ أثناء تغيير حالة الإعلان'), backgroundColor: Colors.red),
  //     );
  //   }
  // }
}