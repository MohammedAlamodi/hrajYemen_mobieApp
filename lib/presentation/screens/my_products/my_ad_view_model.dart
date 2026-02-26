import 'package:flutter/material.dart';

import '../../../model/product_condition.dart';
import '../../../model/product_image_model.dart';
import '../../../model/product_model.dart';
import '../home/home_repo.dart';
// import 'custom_widgets/my_ad_card.dart'; // إذا كنت تحتاجه لأي Enums أخرى

class MyAdViewModel extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // --- State Variables ---
  bool _isLoading = false;
  bool _isEditingLoading = false;
  int _selectedTabIndex = 0; // 0 = نشطة, 1 = منتهية
  List<ProductModel> _allAds = []; // كل الإعلانات

  // المنتج الأصلي (للمقارنة أو التحديث)
  ProductModel? originalProduct;

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isEditingLoading => _isEditingLoading;
  int get selectedTabIndex => _selectedTabIndex;

  // جلب القائمة المعروضة حالياً بناءً على التبويب باستخدام isActive
  List<ProductModel> get currentAds {
    if (_selectedTabIndex == 0) {
      // إرجاع الإعلانات النشطة
      return _allAds.where((ad) => ad.isActive == true).toList();
    } else {
      // إرجاع الإعلانات المنتهية/المباعة
      return _allAds.where((ad) => ad.isActive == false).toList();
    }
  }

  // --- Initialization ---

  /// تهيئة حقول التعديل بالبيانات الحالية للمنتج
  void initControllers(ProductModel product) {
    originalProduct = product;

    titleController.text = product.title;
    priceController.text = product.price?.toStringAsFixed(0) ?? '';
    descController.text = product.description ?? '';

    // تجميع الموقع (مدينة - منطقة) بناءً على القيم القادمة من السيرفر
    String location = '';
    if (product.cityName != null && product.cityName!.isNotEmpty) {
      location += product.cityName!;
    }
    if (product.regionName != null && product.regionName!.isNotEmpty) {
      location += ' - ${product.regionName!}';
    }
    locationController.text = location;
  }

  // --- Actions ---

  /// تغيير التبويب (نشطة / منتهية)
  void changeTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  /// جلب بيانات الإعلانات الخاصة بالمستخدم (محاكاة)
  Future<void> fetchMyAds() async {
    _isLoading = true;
    notifyListeners();

    final HomeRepository _repo = HomeRepository();


    _allAds = await _repo.fetchProducts(page: 1, myProducts: true);

    _isLoading = false;
    notifyListeners();
  }

  /// حفظ التعديلات على الإعلان
  Future<void> saveChanges(BuildContext context) async {
    _isEditingLoading = true;
    notifyListeners();

    // محاكاة الاتصال بالسيرفر
    await Future.delayed(const Duration(seconds: 2));

    _isEditingLoading = false;
    notifyListeners();

    // هنا تضع كود إرسال البيانات للـ API (باستخدام toSubmitJson الذي أنشأناه سابقاً)
    print("Saving: ${titleController.text}, Price: ${priceController.text}");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
      );
      Navigator.pop(context); // الرجوع للخلف بعد الحفظ
    }
  }

  /// حذف إعلان (محاكاة)
  void deleteAd(int id) {
    _allAds.removeWhere((element) => element.id == id);
    notifyListeners();
    // هنا يجب إضافة كود الحذف الفعلي من الـ API
  }

  /// وضع علامة "تم البيع" أو إنهاء الإعلان
  void markAsSold(int id) {
    final index = _allAds.indexWhere((element) => element.id == id);
    if (index != -1) {
      // بما أن الحقول final، نقوم بإنشاء كائن جديد بنفس البيانات مع تغيير isActive
      final oldAd = _allAds[index];
      String userId = oldAd.user?.id ?? '';

      _allAds[index] = ProductModel(
        id: oldAd.id,
        title: oldAd.title,
        description: oldAd.description,
        price: oldAd.price,
        condition: oldAd.condition,
        categoryName: oldAd.categoryName,
        subCategoryName: oldAd.subCategoryName,
        cityName: oldAd.cityName,
        regionName: oldAd.regionName,
        userName: oldAd.userName,
        isActive: false, // 👈 تحويل الحالة إلى مباع
        isFavorite: oldAd.isFavorite,
        mainImageUrl: oldAd.mainImageUrl,
        viewsCount: oldAd.viewsCount,
        createdAt: oldAd.createdAt,
        images: oldAd.images,
      );

      notifyListeners();
      // هنا يجب إضافة كود تحديث الحالة في الـ API
    }
  }

  /// تنسيق التاريخ للعرض في الواجهة
  String formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} أيام';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'الآن';
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descController.dispose();
    locationController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
//
// import '../../../model/product_condition.dart';
// import '../../../model/product_image_model.dart';
// import '../../../model/product_model.dart';
// import 'custom_widgets/my_ad_card.dart';
//
// class MyAdViewModel extends ChangeNotifier {
//   // Controllers للحقول
//   late TextEditingController titleController;
//   late TextEditingController priceController;
//   late TextEditingController descController;
//   late TextEditingController locationController;
//
//   // حالة التحميل
//   bool _isEditingLoading = false;
//   bool get isEditingLoading => _isEditingLoading;
//
//   // المنتج الأصلي (للمقارنة أو التحديث)
//   ProductModel? originalProduct;
//
//     // _initControllers();
//     // fetchMyAds();
//
//
//   bool _isLoading = false;
//   int _selectedTabIndex = 0; // 0 = نشطة, 1 = منتهية
//   List<ProductModel> _allAds = []; // كل الإعلانات
//
//   // --- Getters ---
//   bool get isLoading => _isLoading;
//   int get selectedTabIndex => _selectedTabIndex;
//
//   // جلب القائمة المعروضة حالياً بناءً على التبويب
//   List<ProductModel> get currentAds {
//     if (_selectedTabIndex == 0) {
//       // إرجاع الإعلانات النشطة
//       return _allAds.where((ad) => ad.status == AdStatus.active.toString()).toList();
//     } else {
//       // إرجاع الإعلانات المنتهية/المباعة
//       return _allAds.where((ad) => ad.status == AdStatus.sold.toString()).toList();
//     }
//   }
//
//   void initControllers(ProductModel product) {
//     originalProduct = product;
//
//     titleController = TextEditingController(text: originalProduct!.title);
//     priceController = TextEditingController(text: originalProduct!.price?.toStringAsFixed(0) ?? '');
//     descController = TextEditingController(text: originalProduct!.description);
//
//     // تجميع الموقع (مدينة - منطقة)
//     String location = '';
//     if (originalProduct?.cityName != null) location += originalProduct!.city!.name;
//     if (originalProduct?.region != null) location += ' - ${originalProduct!.region!.name}';
//     locationController = TextEditingController(text: location);
//   }
//
//   // دالة الحفظ (محاكاة)
//   Future<void> saveChanges(BuildContext context) async {
//     _isEditingLoading = true;
//     notifyListeners();
//
//     // محاكاة الاتصال بالسيرفر
//     await Future.delayed(const Duration(seconds: 2));
//
//     _isEditingLoading = false;
//     notifyListeners();
//
//     // هنا تضع كود إرسال البيانات للـ API
//     print("Saving: ${titleController.text}, Price: ${priceController.text}");
//
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('تم تعديل الإعلان بنجاح')),
//       );
//       Navigator.pop(context); // الرجوع للخلف
//     }
//   }
//
//   // تغيير التبويب
//   void changeTab(int index) {
//     _selectedTabIndex = index;
//     notifyListeners();
//   }
//
//   // جلب البيانات (محاكاة)
//   Future<void> fetchMyAds() async {
//     _isLoading = true;
//     notifyListeners();
//
//     await Future.delayed(const Duration(seconds: 1)); // محاكاة الشبكة
//
//     // بيانات وهمية
//     _allAds = [
//       ProductModel(
//         id: 101,
//         title: 'سيارة تويوتا كامري 2021 نظيفة',
//         description: 'سيارة بحالة الوكالة...',
//         price: 85000.0,
//         status: AdStatus.active.toString(),
//         condition: ProductCondition.used,
//         createdAt: DateTime.now().subtract(const Duration(days: 2)),
//         viewsCount: 245,
//         userId: 'user_1',
//         categoryId: 1, subCategoryId: 1, cityId: 1, regionId: 1,
//
//         images: [ProductImageModel(id: 1, imageUrl: "https://arabgt.com/wp-content/uploads/2021/08/%D8%A7%D8%B3%D8%B9%D8%A7%D8%B1-%D9%88%D9%85%D9%88%D8%A7%D8%B5%D9%81%D8%A7%D8%AA-%D8%B3%D9%8A%D8%A7%D8%B1%D9%87-%D9%8A%D8%A7%D8%B1%D8%B3-2021-4.jpg", isMain: true, productId: 101)],
//         // attributes: {'status': 'active'}, // ✅ نشط
//       ),
//       ProductModel(
//         id: 102,
//         title: 'آيفون 14 برو ماكس 256 جيجا',
//         description: 'الجوال جديد لم يستخدم...',
//         status: AdStatus.sold.toString(),
//         price: 4200.0,
//         condition: ProductCondition.newItem,
//         createdAt: DateTime.now().subtract(const Duration(days: 5)),
//         viewsCount: 186,
//         userId: 'user_1',
//         categoryId: 3, subCategoryId: 1, cityId: 1, regionId: 1,
//         images: [ProductImageModel(id: 2, imageUrl: "https://placehold.co/100x100", isMain: true, productId: 102)],
//         // attributes: {'status': 'active'}, // ✅ نشط
//       ),
//       ProductModel(
//         id: 103,
//         title: 'لابتوب ديل XPS 15',
//         description: 'لابتوب قوي للمصممين...',
//         status: AdStatus.active.toString(),
//         price: 3800.0,
//         condition: ProductCondition.used,
//         createdAt: DateTime.now().subtract(const Duration(days: 20)),
//         viewsCount: 312,
//         userId: 'user_1',
//         categoryId: 3, subCategoryId: 1, cityId: 1, regionId: 1,
//         images: [ProductImageModel(id: 3, imageUrl: "https://placehold.co/100x100", isMain: true, productId: 103)],
//         // attributes: {'status': 'sold'}, // ❌ مباع/منتهي
//       ),
//     ];
//
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   // حذف إعلان (محاكاة)
//   void deleteAd(int id) {
//     _allAds.removeWhere((element) => element.id == id);
//     notifyListeners();
//   }
//
//   // وضع علامة مباع (محاكاة)
//   void markAsSold(int id) {
//     final index = _allAds.indexWhere((element) => element.id == id);
//     if (index != -1) {
//       // ننسخ المنتج ونغير حالته (لأن الحقول final)
//       // هنا سنقوم بتحديث الـ Map يدوياً لأن attributes ليست final بالمعنى الحرفي للـ Map content
//       _allAds[index].attributes['status'] = 'sold';
//       notifyListeners();
//     }
//   }
//
//   // تنسيق التاريخ
//   String formatDate(DateTime date) {
//     final diff = DateTime.now().difference(date);
//     if (diff.inDays > 0) return 'منذ ${diff.inDays} أيام';
//     if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
//     return 'الآن';
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     priceController.dispose();
//     descController.dispose();
//     locationController.dispose();
//     super.dispose();
//   }
// }