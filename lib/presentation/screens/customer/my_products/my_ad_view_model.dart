import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/strings_manager.dart';
import 'package:ye_hraj/configurations/user_preferences.dart';
import 'package:ye_hraj/presentation/custom_widgets/en_digits_input_formatter.dart';
import 'package:ye_hraj/presentation/screens/customer/home/home_view_model.dart';

import '../../../../model/product_model.dart';
import '../../../custom_widgets/custom_text.dart';
import '../home/home_repo.dart';
// import 'custom_widgets/my_ad_card.dart'; // إذا كنت تحتاجه لأي Enums أخرى

class MyAdViewModel extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // --- State Variables ---
  bool _isLoading = false;
  bool _isDeletingLoading = false;

  bool get isDeletingLoading => _isDeletingLoading;

  bool _isEditingLoading = false;
  int _selectedTabIndex = 0; // 0 = نشطة, 1 = منتهية
  String condition = '0'; // 0 = نشطة, 1 = منتهية
  List<ProductModel> _allAds = []; // كل الإعلانات

  final HomeRepository _repo = HomeRepository();

  // المنتج الأصلي (للمقارنة أو التحديث)
  ProductModel? originalProduct;

  // --- Getters ---
  bool get isLoading => _isLoading;

  bool get isEditingLoading => _isEditingLoading;

  int get selectedTabIndex => _selectedTabIndex;

  String userId = '';

  // جلب القائمة المعروضة حالياً بناءً على التبويب باستخدام isActive
  List<ProductModel> get currentAds {
    if (_selectedTabIndex == 0) {
      // إرجاع الإعلانات النشطة
      return _allAds.where((ad) => ad.isActive.toString() == 'true').toList();
    } else {
      // إرجاع الإعلانات المنتهية/المباعة
      return _allAds.where((ad) => ad.isActive.toString() == 'false').toList();
    }
  }

  // 🔥 متغيرات العملة
  String priceCurrency = 'ريال يمني'; // العملة الافتراضية
  final List<String> currencies = ['ريال يمني', 'ريال سعودي', 'دولار'];

  // إعدادات التواصل (تظهر كأزرار تبديل في شاشة التعديل)
  bool allowCall = true;
  bool allowChat = true;

  void setAllowCall(bool value) {
    allowCall = value;
    notifyListeners();
  }

  void setAllowChat(bool value) {
    allowChat = value;
    notifyListeners();
  }

  /// تهيئة حقول التعديل بالبيانات الحالية للمنتج
  void initControllers(ProductModel product) {
    originalProduct = product;

    titleController.text = product.title;
    priceController.text = product.price?.toStringAsFixed(0) ?? '';
    descController.text = product.description ?? '';
    // condition = product.condition ?? '1';
    priceCurrency = product.priceCurrency ?? currencies[0];
    allowCall = product.allowCall;
    allowChat = product.allowChat;

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

  // دالة لتغيير العملة (State Update)
  void setCurrency(String? val) {
    if (val != null) {
      priceCurrency = val;
      notifyListeners();
    }
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

    userId = await UserPreferences().getString(
      key: AppStrings.userIdKey,
      defaultValue: 'null',
    ); // هنا يجب جلب الـ userId الحقيقي من بيانات المستخدم الحالي (مثلاً من SharedPreferences أو UserProvider)

    _allAds = [];

    _allAds = await _repo.fetchProducts(
      page: 1,
      limit: 10000,
      myProducts: true,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// حفظ التعديلات على الإعلان

  // --- أضف هذه المتغيرات في بداية الكلاس لإدارة الصور ---
  List<int> deletedImageIds = []; // لتخزين IDs الصور التي يقرر المستخدم حذفها
  // داخل كلاس MyAdViewModel
  List<File> newImages = []; // قائمة الصور الجديدة المضافة من الجهاز
  final ImagePicker _picker = ImagePicker();

  // دالة لاختيار صور جديدة
  Future<void> pickNewImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      newImages.addAll(pickedFiles.map((xFile) => File(xFile.path)).toList());
      notifyListeners();
    }
  }

  // دالة لحذف صورة جديدة (قبل الرفع)
  void removeNewImage(int index) {
    newImages.removeAt(index);
    notifyListeners();
  }

  // تحديث دالة saveChanges لإرسال الصور الجديدة والمحذوفات
  Future<void> editMyAdFun(BuildContext context, ) async {
    if (originalProduct == null) return;

    _isEditingLoading = true;
    notifyListeners();

    try {
      final HomeRepository _repo = HomeRepository();

      // 1. تجهيز البيانات النصية (المفاتيح يجب أن تطابق الـ API)
      final Map<String, dynamic> updateData = {
        'Title': titleController.text.trim(),
        'Description': descController.text.isEmpty
            ? ''
            : descController.text.trim(),
        'Price':
            double.tryParse(toEnglishDigits(priceController.text)) ?? 0.0,
        'PriceCurrency': priceCurrency,
        'AllowCall': allowCall,
        'AllowChat': allowChat,
        'regionId': originalProduct!.regionId,
        'cityId': originalProduct!.cityId,
        'categoryId': originalProduct!.categoryId,
        'subCategoryId': originalProduct!.subCategoryId,
        'Condition': originalProduct!.condition ?? '1',
        'UpdateAt': originalProduct!.updateAt,
      };

      // 2. إضافة الصور المحذوفة (إذا كان السيرفر يدعم استقبالها في FormData)
      if (deletedImageIds.isNotEmpty) {
        for (int i = 0; i < deletedImageIds.length; i++) {
          updateData['DeletedImageIds[$i]'] = deletedImageIds[i];
        }
      }

      final bool success = await _repo.updateProduct(
        productId: originalProduct!.id,
        data: updateData,
        images: newImages,
      );

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar( SnackBar(
              content: CustomText(title:'تم التحديث بنجاح ✅'),
              backgroundColor: Colors.green,
          ));
          await fetchMyAds();
          newImages.clear();
          deletedImageIds.clear();
          if(context.mounted){
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isEditingLoading = false;
      notifyListeners();
    }
  }

  Future<void> editUpdateAtFun(BuildContext context, ) async {

    if (originalProduct == null) return;

    _isEditingLoading = true;
    notifyListeners();

    try {
      final HomeRepository _repo = HomeRepository();

      // 1. تجهيز البيانات النصية (المفاتيح يجب أن تطابق الـ API)
      final Map<String, dynamic> updateData = {
        'Title': originalProduct?.title ?? '',
        'Description': originalProduct?.description ?? '',
        'Price': originalProduct?.price ?? 0.0,
        'PriceCurrency': originalProduct?.priceCurrency ?? currencies[0],
        'Condition': originalProduct!.condition ?? '1',
        'regionId': originalProduct!.regionId,
        'cityId': originalProduct!.cityId,
        'categoryId': originalProduct!.categoryId,
        'subCategoryId': originalProduct!.subCategoryId,
        'UpdateAt': DateTime.now(), // تحديث تاريخ التحديث إلى الوقت الحالي
      };

      final bool success = await _repo.updateProduct(
        productId: originalProduct!.id,
        data: updateData,
        // images: originalProduct.images,
      );

      if (success) {
        if (context.mounted) {
          HomeViewModel homeVM = Provider.of<HomeViewModel>(context, listen: false);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم التحديث بنجاح')));
          await fetchMyAds();
          homeVM.getInitialData();

          newImages.clear();
          deletedImageIds.clear();
          // if(context.mounted){
          //   Navigator.pop(context);
          // }
        }
      }else{
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء التحديث')));
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isEditingLoading = false;
      notifyListeners();
    }
  }

  /// تغيير حالة المنتج (نشط / مباع) في السيرفر
  Future<void> toggleAdStatus(BuildContext context, int productId) async {
    _isEditingLoading = true; // نستخدم لودينج القائمة الرئيسي أو لودينج خاص
    notifyListeners();

    try {
      final HomeRepository _repo = HomeRepository();

      // استدعاء الدالة الموجودة مسبقاً في الـ Repo الخاص بك
      final bool success = await _repo.toggleChangeActiveStatus(productId);

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('تم تغيير حالة الإعلان بنجاح'),
            ),
          );
        }
        // إعادة جلب البيانات لتحديث القوائم (نشطة/منتهية)
        fetchMyAds();
        Navigator.pop(context); // إغلاق الديلوج
      } else {
        throw Exception("فشل تحديث الحالة");
      }
    } catch (e) {
      debugPrint("Error toggling status: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تغيير الحالة')),
        );
      }
    } finally {
      _isEditingLoading = false;
      notifyListeners();
    }
  }

  void removeExistingImage(int imageId) {
    deletedImageIds.add(imageId);
    // كود إضافي لإخفاء الصورة من الواجهة مؤقتاً
    notifyListeners();
  }

  /// حذف إعلان (محاكاة)
  Future<void> deleteAd(BuildContext context, int id) async{
    _isDeletingLoading = true;
    notifyListeners();

    _repo.deleteProduct(id).then((value) {
      _isDeletingLoading = false;
      notifyListeners();

      if (value) {
        if(context.mounted) {
          HomeViewModel homeVM = Provider.of<HomeViewModel>(context, listen: false);
          ScaffoldMessenger.of(
            context,).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text('تم حذف الإعلان بنجاح')

          ));
          fetchMyAds(); // تحديث القائمة بعد الحذف
          homeVM.getInitialData();
          Navigator.pop(context); // إغلاق الديلوج
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text('حدث خطأ أثناء حذف الإعلان')),
        );
      }
    });
  }

  /// وضع علامة "تم البيع" أو إنهاء الإعلان
  void markAsSold(int id) {
    final index = _allAds.indexWhere((element) => element.id == id);
    if (index != -1) {
      // بما أن الحقول final، نقوم بإنشاء كائن جديد بنفس البيانات مع تغيير isActive
      final oldAd = _allAds[index];
      // String userId = oldAd.user?.id ?? '';

      _allAds[index] = ProductModel(
        id: oldAd.id,
        title: oldAd.title,
        description: oldAd.description,
        price: oldAd.price,
        condition: oldAd.condition,
        updateAt: oldAd.updateAt,
        categoryName: oldAd.categoryName,
        subCategoryName: oldAd.subCategoryName,
        cityName: oldAd.cityName,
        regionName: oldAd.regionName,
        userName: oldAd.userName,
        isBlocked: oldAd.isBlocked,
        isActive: false,
        // 👈 تحويل الحالة إلى مباع
        allowCall: oldAd.allowCall,
        allowChat: oldAd.allowChat,
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
