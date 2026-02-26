// view_models/add_ad_view_model.dart
import 'dart:async';
import 'dart:io'; // لاستخدام File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/model/cities_model.dart';
import 'package:ye_hraj/model/region_model.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/screens/common/common_view_model.dart';
import 'package:ye_hraj/presentation/screens/home/home_view_model.dart';

import '../../../../model/category_model.dart';
import '../../home/home_repo.dart';
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

  // --- الخطوة 3: التواصل ---
  bool _hasChat = true;
  bool _hasCall = true;
  bool _hasWhatsApp = false;
  bool _showPhoneNumber = true;

  bool get hasChat => _hasChat;

  bool get hasCall => _hasCall;

  bool get hasWhatsApp => _hasWhatsApp;

  bool get showPhoneNumber => _showPhoneNumber;

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
      case 'whatsapp':
        _hasWhatsApp = !_hasWhatsApp;
        break;
      case 'showPhone':
        _showPhoneNumber = !_showPhoneNumber;
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
      if (_selectedMainCategory == null || titleController.text.isEmpty) {
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

  Future<void> _submitAd(BuildContext context) async {
    HomeViewModel homeVM = Provider.of<HomeViewModel>(context, listen: false);
    // 1. تفعيل حالة التحميل
    _isLoadingPostAd = true;
    notifyListeners();

    // 2. تجهيز البيانات حسب متطلبات الـ API بالضبط
    Map<String, dynamic> productData = {
      'Title': titleController.text.trim(),
      'Description': descriptionController.text.trim(),
      'Price': double.tryParse(priceController.text.trim()) ?? 0.0,

      // إعدادات التواصل
      'AllowChat': _hasChat,
      'AllowCall': _hasCall,
      'AllowWhatsApp': _hasWhatsApp,
      'ShowPhoneNumber': _showPhoneNumber,

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
          content: Text('تم نشر الإعلان بنجاح! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      // إغلاق الشاشة والعودة للرئيسية
      Navigator.pop(context);

      // 💡 تلميح: هنا يفضل استدعاء دالة لتحديث قائمة الإعلانات في الصفحة الرئيسية
      // Provider.of<HomeViewModel>(context, listen: false).getInitialData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء النشر، يرجى المحاولة لاحقاً.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
