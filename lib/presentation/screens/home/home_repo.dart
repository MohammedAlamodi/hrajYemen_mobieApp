import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';

import '../../../configurations/data/api_services.dart';
import '../../../model/category_model.dart';
import '../../../model/product_model.dart';

class HomeRepository {

  Future<List<ProductModel>> fetchProducts({
    required int page,
    int limit = 5,
    String? search,
    int? categoryId,
    int? subCategoryId,
    int? cityId,
    double? minPrice,
    double? maxPrice,
    int? condition, // 1 أو 2
    bool myProducts = false,
    bool myFavorites = false,
    bool? isActive,
    String? orderBy,
    bool ascendingOrder = false,
  }) async {
    await ApiService().getToken();

    try {
      // 1. تجهيز الفلاتر (Parameters)
      Map<String, dynamic> queryParams = {
        'PageNumber': page,
        'PageSize': limit,
        'myProducts': myProducts,
        'myFavorites': myFavorites,
        'FilterQuery.AscendingOrder': ascendingOrder,
      };

      // إضافة الفلاتر التي لها قيمة فقط
      if (search != null && search.isNotEmpty) queryParams['FilterQuery.Search'] = search;
      if (categoryId != null) queryParams['FilterQuery.CategoryId'] = categoryId;
      if (subCategoryId != null) queryParams['FilterQuery.SubCategoryId'] = subCategoryId;
      if (cityId != null) queryParams['FilterQuery.CityId'] = cityId;
      if (minPrice != null) queryParams['FilterQuery.MinPrice'] = minPrice;
      if (maxPrice != null) queryParams['FilterQuery.MaxPrice'] = maxPrice;
      if (condition != null) queryParams['FilterQuery.Condition'] = condition;
      if (isActive != null) queryParams['isActive'] = isActive;
      if (orderBy != null && orderBy.isNotEmpty) queryParams['FilterQuery.OrderBy'] = orderBy;

      // 2. إرسال الطلب للسيرفر
      // تأكد أن المسار 'api/Products' صحيح حسب مشروعك
      final response = await ApiService().dio.get(
        EndPointsStrings.getProductsEndPoint,
        queryParameters: queryParams,
      );

      // 3. معالجة الاستجابة
      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;

        // التحقق أن البيانات تحتوي على المفتاح "items"
        if (data is Map && data['items'] != null) {
          List<ProductModel> products = (data['items'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();

          return products;
        }
      }

      return []; // إرجاع قائمة فارغة إذا لم تكن هناك بيانات

    } on DioException catch (e) {
      debugPrint("خطأ شبكة في جلب المنتجات: ${e.message}");
      return [];
    } catch (e) {
      debugPrint("خطأ في معالجة المنتجات: $e");
      return [];
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    await ApiService().getToken();

    try {
      // 1. الاتصال بالـ API (تأكد من تعديل الرابط ليتناسب مع مشروعك)
      final response = await ApiService().dio.get(EndPointsStrings.getCategoriesEndPoint); // أو حسب مسار الـ API عندك

      // 2. معالجة البيانات (لأنها ترجع مصفوفة مباشرة List)
      if (response.statusCode == 200 && response.data != null) {

        // التحقق مما إذا كانت البيانات مصفوفة مباشرة (مثل الـ JSON الذي أرسلته)
        if (response.data is List) {
          List<CategoryModel> categories = (response.data as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
          return categories;
        }
        // أو إذا كانت مغلفة بـ data (احتياطياً)
        else if (response.data is Map && response.data['data'] != null) {
          List<CategoryModel> categories = (response.data['data'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
          return categories;
        }
      }

      return []; // إرجاع قائمة فارغة إذا لم تكن هناك بيانات

    } on DioException catch (e) {
      // ⚠️ معالجة أخطاء الشبكة
      debugPrint("خطأ في الاتصال بالشبكة (Categories): ${e.message}");
      return [];

    } catch (e) {
      // ⚠️ معالجة أخطاء التحويل (Parsing)
      debugPrint("خطأ في تحويل بيانات الأقسام: $e");
      return [];
    }
  }

  /// جلب الأقسام الفرعية (SubCategories) لقسم معين
  Future<List<SubCategoryModel>> fetchSubCategories(int categoryId) async {
    await ApiService().getToken();

    try {
      // إرسال الـ categoryId كـ Query Parameter أو حسب مسار الـ API لديكم
      // مثال: api/Categories/1/SubCategories أو api/SubCategories?categoryId=1
      final response = await ApiService().dio.get(
        '${EndPointsStrings.getSubCategoriesEndPoint}/$categoryId', // أو حسب مسار الـ API عندك
      );

      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;

        // إذا كان الرد مصفوفة مباشرة (List)
        if (data is List) {
          return data.map((e) => SubCategoryModel.fromJson(e)).toList();
        }
        // إذا كان مغلفاً بـ data أو items
        else if (data is Map && data['items'] != null) {
          return (data['items'] as List).map((e) => SubCategoryModel.fromJson(e)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print("خطأ شبكة في جلب الأقسام الفرعية: ${e.message}");
      return [];
    } catch (e) {
      print("خطأ في معالجة الأقسام الفرعية: $e");
      return [];
    }
  }

  Future<ProductModel?> fetchProductDetails(int productId) async {
    try {
      // 1. الاتصال بالسيرفر (تأكد أن المسار يطابق الـ API الخاص بك)
      final response = await ApiService().dio.get('${EndPointsStrings.getProductsEndPoint}/$productId');

      // 2. معالجة الاستجابة
      if (response.statusCode == 200 && response.data != null) {

        if (response.data is Map<String, dynamic>) {
          return ProductModel.fromJson(response.data);
        }
      }

      return null; // إذا لم يجد المنتج أو كانت البيانات فارغة

    } on DioException catch (e) {
      // ⚠️ معالجة أخطاء الشبكة
      if (e.response?.statusCode == 404) {
        debugPrint("خطأ: هذا الإعلان غير موجود أو تم حذفه.");
      } else {
        debugPrint("خطأ شبكة في جلب تفاصيل المنتج: ${e.message}");
      }
      return null;

    } catch (e) {
      // ⚠️ معالجة أخطاء التحويل (Parsing)
      debugPrint("خطأ في معالجة تفاصيل المنتج: $e");
      return null;
    }
  }

  Future<bool> createProduct({
    required Map<String, dynamic> data,
    required List<File> images,
  }) async {
    try {

      // 1. إنشاء كائن FormData
      FormData formData = FormData.fromMap(data);

      // 2. إضافة الصور إلى الـ FormData
      for (int i = 0; i < images.length; i++) {
        formData.files.add(
          MapEntry(
            'Images', // 👈 يجب أن يطابق هذا الاسم تماماً اسم الـ Array في الـ API
            await MultipartFile.fromFile(
              images[i].path,
              filename: images[i].path.split('/').last,
            ),
          ),
        );
      }

      await ApiService().getToken();

      // 3. إرسال الطلب للسيرفر (POST)
      final response = await ApiService().dio.post(
        EndPointsStrings.createProductsEndPoint, // 👈 تأكد من مسار الـ API الصحيح للإنشاء
        data: formData,
      );

      // 4. التحقق من النجاح (عادة 200 أو 201 تعني تم الإنشاء بنجاح)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;

    } on DioException catch (e) {
      print("خطأ أثناء رفع الإعلان: ${e.message}");
      if (e.response != null) {
        print("تفاصيل الخطأ من السيرفر: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      print("خطأ غير متوقع: $e");
      return false;
    }
  }
}