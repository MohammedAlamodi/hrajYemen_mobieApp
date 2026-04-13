import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../model/cities_model.dart';
import '../../../../model/region_model.dart';
import '../../common/common_rep.dart';

class CitiesAdminVM extends ChangeNotifier {
  final CommonViewRepository _repo = CommonViewRepository();

  bool isLoading = false;
  bool isActionLoading = false;

  List<CitiesModel> cities = [];

  // حفظ المناطق لكل مدينة على حدة لتشغيل الـ Accordion بنجاح
  Map<int, List<RegionModel>> regionsMap = {};
  Set<int> expandedCities = {};

  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController regionNameController = TextEditingController();

  CitiesAdminVM() {
    fetchAllCities();
  }

  // ==================== 1. المدن (Cities) ====================

  Future<void> fetchAllCities() async {
    isLoading = true;
    notifyListeners();

    try {
      // جلب المدن باستخدام الدالة الموجودة في الريبو الخاص بكم
      cities = await _repo.fetchCities();
    } catch (e) {
      debugPrint('Error fetching cities in Admin: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // التحكم بفتح وإغلاق القائمة المنسدلة للمناطق
  Future<void> toggleCityExpansion(int cityId) async {
    if (expandedCities.contains(cityId)) {
      expandedCities.remove(cityId);
    } else {
      expandedCities.add(cityId);
      // إذا لم تكن المناطق محملة مسبقاً، نجلبها من السيرفر
      if (!regionsMap.containsKey(cityId)) {
        await loadRegionsFor(cityId);
      }
    }
    notifyListeners();
  }

  Future<void> saveOrUpdateCity(BuildContext context, {int? cityId}) async {
    if (cityNameController.text.trim().isEmpty) return;

    isActionLoading = true;
    notifyListeners();

    bool isSuccess = false;
    try {
      if (cityId == null) {
        // TODO: أضف دالة createCity في الـ CommonViewRepository
        isSuccess = await _repo.createCity(cityNameController.text);
      } else {
        // TODO: أضف دالة updateCity في الـ CommonViewRepository
        isSuccess = await _repo.updateCity(cityId, cityNameController.text);
      }
    } catch (e) {
      debugPrint('Error saving city: $e');
    }

    isActionLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pop(context);
      if (isSuccess) {
        cityNameController.clear();
        fetchAllCities(); // تحديث القائمة من السيرفر
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحفظ!'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> deleteCity(BuildContext context, int cityId) async {
    try {
      // TODO: أضف دالة deleteCity في الـ CommonViewRepository
      bool isSuccess = await _repo.deleteCity(cityId);
      // bool isSuccess = true; // للتجربة، استبدلها بالسطر أعلاه

      if (isSuccess) {
        fetchAllCities();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف!'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      debugPrint('Error deleting city: $e');
    }
  }

  void prepareCityForEdit(CitiesModel city) {
    cityNameController.text = city.name ?? '';
  }

  // ==================== 2. المناطق (Regions) ====================

  Future<void> loadRegionsFor(int cityId) async {
    try {
      // جلب المناطق من السيرفر بناءً على الكود الخاص بكم
      final regions = await _repo.fetchRegion(cityId);
      regionsMap[cityId] = regions;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching regions in Admin: $e');
    }
  }

  Future<void> saveOrUpdateRegion(BuildContext context, int cityId, {int? regionId}) async {
    if (regionNameController.text.trim().isEmpty) return;

    isActionLoading = true;
    notifyListeners();

    bool isSuccess = false;
    try {
      if (regionId == null) {
        // TODO: أضف دالة createRegion في الـ CommonViewRepository
        isSuccess = await _repo.createRegion(cityId, regionNameController.text);
      } else {
        // TODO: أضف دالة updateRegion في الـ CommonViewRepository
        isSuccess = await _repo.updateRegion(regionId, cityId, regionNameController.text);
      }
    } catch (e) {
      debugPrint('Error saving region: $e');
    }

    isActionLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pop(context);
      if (isSuccess) {
        regionNameController.clear();
        await loadRegionsFor(cityId); // جلب المناطق المحدثة من السيرفر
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحفظ!'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> deleteRegion(BuildContext context, int cityId, int regionId) async {
    try {
      // TODO: أضف دالة deleteRegion في الـ CommonViewRepository
      bool isSuccess = await _repo.deleteRegion(regionId);

      if (isSuccess) {
        await loadRegionsFor(cityId); // تحديث القائمة فوراً
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف!'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      debugPrint('Error deleting region: $e');
    }
  }

  void prepareRegionForEdit(RegionModel region) {
    regionNameController.text = region.name ?? '';
  }
}