// view_models/add_ad_view_model.dart
import 'dart:async';
import 'dart:io'; // لاستخدام File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/model/cities_model.dart';
import 'package:ye_hraj/model/product_model.dart';
import 'package:ye_hraj/model/region_model.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/en_digits_input_formatter.dart';
import 'package:ye_hraj/presentation/screens/common/common_view_model.dart';
import '../../../../../model/category_model.dart';
import '../../../../custom_widgets/custom_button.dart';
import '../../home/home_repo.dart';
import '../../home/home_view_model.dart';
// import 'package:image_picker/image_picker.dart'; // تحتاج لهذه المكتبة فعلياً

class AddAdViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool _isLoadingPostAd = false;

  bool get isLoadingPostAd => _isLoadingPostAd;

  bool _isAgreeToPostAd = false;

  bool get isAgreeToPostAd => _isAgreeToPostAd;

  // --- التحكم في الخطوات ---
  int _currentStep = 1;
  final int totalSteps = 4;

  int get currentStep => _currentStep;

  late CommonViewModel commonViewModel;

  // --- الخطوة 1: التفاصيل (موجودة سابقاً) ---
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  CategoryModel? _selectedMainCategory;
  SubCategoryModel? _selectedSubCategory;
  RegionModel? _selectedRegion;
  int _condition = 1;
  CitiesModel? _selectedCity;

  // Getters للخطوة 1
  CategoryModel? get selectedMainCategory => _selectedMainCategory;

  SubCategoryModel? get selectedSubCategory => _selectedSubCategory;

  RegionModel? get selectedRegion => _selectedRegion;

  int get condition => _condition;

  CitiesModel? get selectedCity => _selectedCity;

  // --- الخطوة 2: الصور ---
  List<File> _images = []; // سنستخدم File للصور الحقيقية
  List<File> get images => _images;

  // --- الخطوة 3: التواصل (خياران فقط) ---
  bool _hasChat = true;
  bool _hasCall = true;

  bool get hasChat => _hasChat;

  bool get hasCall => _hasCall;

  // 🔥 متغيرات العملة
  String priceCurrency = 'ريال يمني'; // العملة الافتراضية
  final List<String> currencies = ['ريال يمني', 'ريال سعودي', 'دولار'];

  // ✅ تحديث الفئة الرئيسية وجلب الفرعية بناءً عليها
  void setMainCategory(BuildContext context, int? categoryId) {
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    if (categoryId == null) return;

    if (categoryId.toString() == _selectedMainCategory?.id.toString()) return;

    for (var cat in commonViewModel.categoriesList) {
      if (cat.id.toString() == categoryId.toString()) {
        _selectedMainCategory = cat;
        break;
      }
    }
    _selectedSubCategory = null; // تصفير الفرعي

    // محاكاة جلب فئات فرعية مختلفة حسب الاختيار
    commonViewModel.updateSubCategories(categoryId);

    notifyListeners();
  }

  void setSubCategory(BuildContext context, int? id) {
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    if (id == null) return;

    if (id.toString() == _selectedSubCategory?.id.toString()) return;
    for (var sub in commonViewModel.subCategories) {
      if (sub.id.toString() == id.toString()) {
        _selectedSubCategory = sub;
        break;
      }
    }
    notifyListeners();
  }

  void setCondition(int value) {
    _condition = value;
    notifyListeners();
  }

  void setCity(BuildContext context, int? cityId) {
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    if (cityId == null) return;

    if (cityId.toString() == _selectedCity?.id.toString()) return;

    for (var cat in commonViewModel.cities) {
      if (cat.id.toString() == cityId.toString()) {
        _selectedCity = cat;
        break;
      }
    }
    _selectedRegion = null; // تصفير الفرعي

    // محاكاة جلب فئات فرعية مختلفة حسب الاختيار
    commonViewModel.updateRegionsOfSelectedCity(context, cityId);

    notifyListeners();
  }

  void setRegion(BuildContext context, int? id) {
    commonViewModel = Provider.of<CommonViewModel>(context, listen: false);
    if (id == null) return;

    if (id.toString() == _selectedRegion?.id.toString()) return;

    for (var reg in commonViewModel.regions) {
      if (reg.id.toString() == id.toString()) {
        _selectedRegion = reg;
        break;
      }
    }
    notifyListeners();
  }

  // محاكاة إضافة صورة
  void pickImage() async {
    // هنا كود ImagePicker
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _images.add(File(picked.path));
      notifyListeners();
    }
    print("Simulate picking image");
    notifyListeners();
  }

  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  void toggleContactMethod(String method) {
    switch (method) {
      case 'chat':
        _hasChat = !_hasChat;
        break;
      case 'call':
        _hasCall = !_hasCall;
        break;
    }
    notifyListeners();
  }

  // دالة الرجوع
  void previousStep(BuildContext context) {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    } else {
      Navigator.pop(context);
    }
  }

  // دالة التالي
  void nextStep(BuildContext context) {
    if (_currentStep == 1) {
      _isAgreeToPostAd = false;
    }

    if (!validateStep(context)) return;

    if (_currentStep < totalSteps) {
      _currentStep++;
      notifyListeners();
    } else {
      // وصلنا للخطوة الأخيرة (نشر)
      _submitAd(context);
    }
  }

  bool validateStep(BuildContext context) {
    if (_currentStep == 1) {
      if (_selectedMainCategory == null || _selectedSubCategory == null || titleController.text.isEmpty|| descriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              title: 'أكمل البيانات الإجبارية',
              color: Colors.white,
              size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
            ),
          ),
        );
        return false;
      }
    }
    // يمكن إضافة شروط للصور (مثلا صورة واحدة على الأقل)
    return true;
  }

  void setAgreeToPostAd(bool bool) {
    _isAgreeToPostAd = bool;
    notifyListeners();
  }

// دالة لتغيير العملة (State Update)
  void setCurrency(String? val) {
    if (val != null) {
      priceCurrency = val;
      notifyListeners();
    }
  }

// ==========================================
// 🔥 دالة التحقق من مرور 24 ساعة على آخر تعديل
// ==========================================
  /// قم باستدعاء هذه الدالة عندما يضغط المستخدم على أيقونة "تعديل الإعلان"
  /// إذا أرجعت false، فهذا يعني أنه لا يمكنه التعديل وتم عرض الديالوج له.
  bool canEditProduct(BuildContext context, DateTime? updateAt) {
    if (updateAt == null) return true; // إذا لم يتم تعديله من قبل

    final now = DateTime.now();
    final difference = now.difference(updateAt);

    if (difference.inHours < 24) {
      final remainingHours = 24 - difference.inHours;

      // عرض رسالة المنع (Dialog)
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const CustomText(title: 'تنبيه', color: Colors.red,
              fontWeight: FontWeight.bold
          ),
          content: CustomText(
            title: 'لا يمكنك تعديل الإعلان إلا بعد مرور 24 ساعة من آخر تحديث.\n\nيتبقى تقريباً: $remainingHours ساعة.',
            size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: CustomText(
              title:'حسناً',
                  color: AppColors.current.primary,
                  fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      );
      return false; // لا تسمح له بالانتقال لشاشة التعديل
    }

    return true; // مسموح له بالتعديل
  }

  Future<void> _submitAd(BuildContext context) async {
    HomeViewModel homeVM = Provider.of<HomeViewModel>(context, listen: false);
    // 1. تفعيل حالة التحميل
    _isLoadingPostAd = true;
    notifyListeners();

    // 2. تجهيز البيانات حسب متطلبات الـ API بالضبط
    Map<String, dynamic> productData = {
      'Title': titleController.text.trim(),
      'Description': descriptionController.text.trim(),
      'Price':
          double.tryParse(toEnglishDigits(priceController.text.trim())) ?? 0.0,

      // إعدادات التواصل (خياران فقط)
      'AllowChat': _hasChat,
      'AllowCall': _hasCall,
      'PriceCurrency': priceCurrency,

      // الـ IDs (نرسل القيم فقط إذا لم تكن null)
      if (_selectedMainCategory != null)
        'CategoryId': _selectedMainCategory!.id,
      if (_selectedSubCategory != null)
        'SubCategoryId': _selectedSubCategory!.id,
      if (_selectedCity != null) 'CityId': _selectedCity!.id,
      if (_selectedRegion != null) 'RegionId': _selectedRegion!.id,
    };

    // معالجة حالة المنتج (Condition) لأن الـ API يقبل 1 أو 2
    // بافتراض أن 0 تعني لم يختر شيئاً، لا نرسلها أو نعالجها حسب منطق تطبيقك
    if (_condition == 1 || _condition == 2) {
      productData['Condition'] = _condition;
    }

    // 3. استدعاء السيرفر لرفع البيانات والصور
    bool isSuccess = await _repo.createProduct(
      data: productData,
      images: _images,
    );

    // 4. إيقاف حالة التحميل
    _isLoadingPostAd = false;
    notifyListeners();

    // 5. التحقق من بقاء الشاشة مفتوحة (Context Mounted)
    if (!context.mounted) return;

    // 6. التعامل مع النتيجة (نجاح أو فشل)
    if (isSuccess) {
      homeVM.getInitialData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(title:'تم نشر الإعلان بنجاح! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      clearData();

      // إغلاق الشاشة والعودة للرئيسية
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(title: 'حدث خطأ أثناء النشر، يرجى المحاولة لاحقاً.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void clearData() {
    titleController.clear();
    priceController.clear();
    descriptionController.clear();
    _selectedMainCategory = null;
    _selectedSubCategory = null;
    _selectedRegion = null;
    _condition = 1;
    _currentStep = 1;
    _isAgreeToPostAd = false;
    _selectedCity = null;
    _images.clear();
    _hasChat = true;
    _hasCall = true;
    priceCurrency = 'ريال يمني';
    notifyListeners();
  }

  // Future<void> editUpdateAtFun(BuildContext context, ProductModel? originalProduct) async {
  //   if (originalProduct == null) return;
  //
  //   // _isEditingLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     final HomeRepository _repo = HomeRepository();
  //
  //     // 1. تجهيز البيانات النصية (المفاتيح يجب أن تطابق الـ API)
  //     final Map<String, dynamic> updateData = {
  //       'Title': originalProduct?.title ?? '',
  //       'Description': originalProduct?.description ?? '',
  //       'Price': originalProduct?.price ?? 0.0,
  //       'PriceCurrency': originalProduct?.priceCurrency ?? currencies[0],
  //       'Condition': originalProduct!.condition ?? '1',
  //       'UpdateAt': DateTime.now(), // تحديث تاريخ التحديث إلى الوقت الحالي
  //     };
  //
  //     final bool success = await _repo.updateProduct(
  //       productId: originalProduct!.id,
  //       data: updateData,
  //       // images: originalProduct.images,
  //     );
  //
  //     if (success) {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(const SnackBar(content: Text('تم التحديث بنجاح')));
  //         await fetchMyAds();
  //         newImages.clear();
  //         deletedImageIds.clear();
  //         Navigator.pop(context);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error: $e");
  //   } finally {
  //     _isEditingLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> refProduct(BuildContext context, id) async {
    HomeViewModel homeVM = Provider.of<HomeViewModel>(context, listen: false);
    _isLoadingPostAd = true;
    notifyListeners();

    bool isSuccess = await _repo.refProduct(context, id);

    _isLoadingPostAd = false;
    notifyListeners();

    if (!context.mounted) return;

    if (isSuccess) {
      homeVM.getInitialData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(title:'تم إعادة تنشيط الإعلان بنجاح! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(title: 'حدث خطأ أثناء إعادة التنشيط، يرجى المحاولة لاحقاً.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
