import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';
import '../../../../configurations/user_preferences.dart';
import '../../../../model/category_model.dart';
import '../../../../model/product_model.dart'; // مسار الـ SubCategoryModel
import '../../customer/home/home_repo.dart';

class CategoriesAdminVM extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool isLoading = false;
  bool isActionLoading = false;

  List<CategoryModel> categories = [];
  Map<int, List<SubCategoryModel>> subCategoriesMap = {};
  Set<int> expandedCategories = {};

  final TextEditingController catNameController = TextEditingController();
  final TextEditingController subCatNameController = TextEditingController();

  // المتغيرات الخاصة بالصورة
  String? catIconUrl;
  XFile? selectedImage;
  Uint8List? webImageBytes;
  String baseUrl = EndPointsStrings.baseUrl; // 👈 متغير لحفظ الرابط الأساسي

  CategoriesAdminVM() {
    _init();
  }

  // ==================== التهيئة وجلب الرابط الأساسي ====================
  Future<void> _init() async {
    // baseUrl = EndPointsStrings.baseUrl;

    // لضمان وجود سلاش في نهاية الرابط حتى لا يحدث خطأ عند دمج المسار
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }

    await fetchAllCategories();
  }

  // 👈 دالة سحرية لمعالجة روابط الصور أينما كانت
  String getFullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http')) return path; // إذا كان الرابط كاملاً أصلاً من السيرفر

    // تنظيف المسار من السلاش الأولية (إذا كانت موجودة) حتى لا يصبح لدينا // في الرابط
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // debugPrint('Constructing full image URL: baseUrl="$baseUrl", path="$path", cleanPath="$cleanPath"');

    return '$baseUrl$cleanPath'; // دمج الرابط الأساسي مع مسار الصورة
  }


  // ==================== دوال اختيار الصورة ====================
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage = image;
      webImageBytes = await image.readAsBytes();
      notifyListeners(); // هذا سيقوم بتحديث الديالوج فوراً بفضل ListenableBuilder
    }
  }

  void clearSelectedImage() {
    selectedImage = null;
    webImageBytes = null;
    catIconUrl = null;
    notifyListeners();
  }

  // ==================== الفئات الرئيسية (Categories) ====================

  Future<void> fetchAllCategories() async {
    isLoading = true;
    notifyListeners();
    categories = await _repo.fetchCategories();
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleCategoryExpansion(int categoryId) async {
    if (expandedCategories.contains(categoryId)) {
      expandedCategories.remove(categoryId);
    } else {
      expandedCategories.add(categoryId);
      if (!subCategoriesMap.containsKey(categoryId)) {
        await loadSubCategoriesFor(categoryId);
      }
    }
    notifyListeners();
  }

  Future<void> saveOrUpdateCategory(BuildContext context, {int? categoryId}) async {
    if (catNameController.text.trim().isEmpty) return;

    isActionLoading = true;
    notifyListeners();

    bool isSuccess = false;
    try {
      if (categoryId == null) {
        isSuccess = await _repo.createCategory(name: catNameController.text, image: selectedImage);
        isSuccess = true; // ضع الدالة الحقيقية هنا
      } else {
        isSuccess = await _repo.updateCategory(categoryId, catNameController.text, selectedImage);
        isSuccess = true; // ضع الدالة الحقيقية هنا
      }
    } catch (e) {
      debugPrint('Error saving category: $e');
    }

    isActionLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pop(context);
      if (isSuccess) {
        catNameController.clear();
        clearSelectedImage();
        fetchAllCategories();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحفظ!'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> deleteCategory(BuildContext context, int categoryId) async {
    try {
      // 👈 استدعاء الـ API الحقيقي لحذف الفئة
      bool isSuccess = await _repo.deleteCategory(categoryId);

      if (isSuccess) {
        fetchAllCategories();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف!'), backgroundColor: Colors.red));
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  void prepareCategoryForEdit(CategoryModel category) {
    catNameController.text = category.name;
    catIconUrl = category.imageUrl;
    selectedImage = null;
    webImageBytes = null;
  }

  // ==================== الفئات الفرعية (SubCategories) ====================

  Future<void> loadSubCategoriesFor(int categoryId) async {
    final subCats = await _repo.fetchSubCategories(categoryId);
    subCategoriesMap[categoryId] = subCats;
    notifyListeners();
  }

  Future<void> saveOrUpdateSubCategory(BuildContext context, int categoryId, {int? subCatId}) async {
    if (subCatNameController.text.trim().isEmpty) return;

    isActionLoading = true;
    notifyListeners();

    bool isSuccess = false;
    try {
      if (subCatId == null) {
        // 👈 استدعاء الـ API الحقيقي لإضافة الفئة الفرعية
        isSuccess = await _repo.createSubCategory(categoryId, subCatNameController.text);
      } else {
        // 👈 استدعاء الـ API الحقيقي لتعديل الفئة الفرعية
        isSuccess = await _repo.updateSubCategory(subCatId, categoryId, subCatNameController.text);
      }
    } catch (e) {
      debugPrint('Error saving subcategory: $e');
    }

    isActionLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pop(context);
      if (isSuccess) {
        subCatNameController.clear();
        await loadSubCategoriesFor(categoryId); // جلب التحديث من السيرفر فوراً
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحفظ!'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> deleteSubCategory(BuildContext context, int categoryId, int subCatId) async {
    try {
      // 👈 استدعاء الـ API الحقيقي لحذف الفئة الفرعية
      bool isSuccess = await _repo.deleteSubCategory(subCatId);

      if (isSuccess) {
        await loadSubCategoriesFor(categoryId); // جلب التحديث من السيرفر فوراً
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف!'), backgroundColor: Colors.red));
      }
    } catch (e) {
      debugPrint('Error deleting subcategory: $e');
    }
  }

  void prepareSubCategoryForEdit(SubCategoryModel subCat) {
    subCatNameController.text = subCat.name;
  }
}