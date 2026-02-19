// view_models/add_ad_view_model.dart
import 'dart:async';
import 'dart:io'; // لاستخدام File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';

import '../../../../model/category_model.dart';
import '../../home/home_repo.dart';
// import 'package:image_picker/image_picker.dart'; // تحتاج لهذه المكتبة فعلياً

class AddAdViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool _isLoadingPostAd = false;

  bool get isLoadingPostAd => _isLoadingPostAd;

  bool _isLoadingCategories = false;

  bool get isLoadingCategories => _isLoadingCategories;

  bool _isAgreeToPostAd = false;

  bool get isAgreeToPostAd => _isAgreeToPostAd;

  // --- التحكم في الخطوات ---
  int _currentStep = 1;
  final int totalSteps = 4;

  int get currentStep => _currentStep;

  // --- الخطوة 1: التفاصيل (موجودة سابقاً) ---
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? _selectedMainCategory;
  String? _selectedSubCategory;
  String _condition = 'new';
  String? _selectedCity;

  // Getters للخطوة 1
  String? get selectedMainCategory => _selectedMainCategory;

  String? get selectedSubCategory => _selectedSubCategory;

  String get condition => _condition;

  String? get selectedCity => _selectedCity;

  // --- الخطوة 2: الصور ---
  List<File> _images = []; // سنستخدم File للصور الحقيقية
  List<File> get images => _images;

  // القوائم والبيانات
  List<CategoryModel> _categoriesList = []; // القائمة الخام من الموديل
  List<String> _subCategoriesList = []; // القائمة الفرعية الحالية

  List<String> get mainCategories =>
      _categoriesList.map((e) => e.name).toList();

  List<String> get subCategories => _subCategoriesList;

  // قائمة المدن (ممكن نجيبها من الريبو كمان مستقبلاً)
  final List<String> cities = [
    'المكلا',
    'عدن',
    'صنعاء',
    'تعز',
    'جدة',
    'الرياض',
  ];

  // ✅ Constructor: نجلب البيانات أول ما يشتغل الكلاس
  AddAdViewModel() {
    _fetchCategoriesFromRepo();
  }

  // ✅ جلب الفئات من HomeRepository
  Future<void> _fetchCategoriesFromRepo() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      // نستخدم الدالة الموجودة مسبقاً في الريبو
      _categoriesList = await _repo.fetchCategories();
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // ✅ تحديث الفئة الرئيسية وجلب الفرعية بناءً عليها
  void setMainCategory(String? value) {
    if (value == _selectedMainCategory) return;

    _selectedMainCategory = value;
    _selectedSubCategory = null; // تصفير الفرعي

    // محاكاة جلب فئات فرعية مختلفة حسب الاختيار
    _updateSubCategories(value);

    notifyListeners();
  }

  void _updateSubCategories(String? mainCategory) {
    // هنا منطق محاكاة (في الواقع ستطلب API يرجع لك الـ SubCategories)
    if (mainCategory == 'سيارات') {
      _subCategoriesList = [
        'تويوتا',
        'هونداي',
        'كيا',
        'نيسان',
        'فورد',
        'مرسيدس',
      ];
    } else if (mainCategory == 'عقارات') {
      _subCategoriesList = [
        'شقق للإيجار',
        'فلل للبيع',
        'أراضي',
        'عمارة تجارية',
      ];
    } else if (mainCategory == 'أجهزة') {
      _subCategoriesList = ['جوالات', 'لابتوبات', 'تلفزيونات', 'سماعات'];
    } else if (mainCategory == 'أزياء') {
      _subCategoriesList = ['ملابس رجالية', 'ملابس نسائية', 'أحذية', 'ساعات'];
    } else {
      _subCategoriesList = ['أخرى'];
    }
  }

  void setSubCategory(String? value) {
    _selectedSubCategory = value;
    notifyListeners();
  }

  void setCondition(String value) {
    _condition = value;
    notifyListeners();
  }

  void setCity(String? value) {
    _selectedCity = value;
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

  // --- الخطوة 3: التواصل ---
  bool _hasChat = true;
  bool _hasCall = true;
  bool _hasWhatsApp = false;
  bool _showPhoneNumber = true;

  bool get hasChat => _hasChat;

  bool get hasCall => _hasCall;

  bool get hasWhatsApp => _hasWhatsApp;

  bool get showPhoneNumber => _showPhoneNumber;

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

  void updateAgreeToPostAd(bool value) {
    _isAgreeToPostAd = value;
    notifyListeners();
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

  // النشر النهائي
  void _submitAd(BuildContext context) {
    _isLoadingPostAd = true;
    notifyListeners();

    Timer(const Duration(seconds: 5), () {});

    _isLoadingPostAd = false;
    notifyListeners();
    // هنا ترسل البيانات للسيرفر
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم نشر الإعلان بنجاح!')));

    _isLoadingPostAd = true;
    notifyListeners();
    Navigator.pop(context);
  }

  void setAgreeToPostAd(bool bool) {
    _isAgreeToPostAd = bool;
    notifyListeners();
  }


  // Setters للخطوة 1 (مختصرة)
  // void setMainCategory(String? v) { _selectedMainCategory = v; notifyListeners(); }
  // void setSubCategory(String? v) { _selectedSubCategory = v; notifyListeners(); }
  // void setCondition(String v) { _condition = v; notifyListeners(); }
  // void setCity(String? v) { _selectedCity = v; notifyListeners(); }
}
