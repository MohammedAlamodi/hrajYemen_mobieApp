import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';

import '../../../../configurations/data/api_services.dart';
import '../../../../model/admin_stats_model.dart';
import '../../../../model/admin_user_model.dart';
import '../../../../model/category_model.dart';
import '../../../../model/product_image_model.dart';
import '../../../../model/product_model.dart';

class HomeRepository {
  // Future<List<ProductModel>> fetchProducts({
  //   required int page,
  //   int limit = 5,
  //   String? search,
  //   int? categoryId,
  //   int? subCategoryId,
  //   int? cityId,
  //   double? minPrice,
  //   double? maxPrice,
  //   int? condition, // 1 أو 2
  //   bool myProducts = false,
  //   bool myFavorites = false,
  //   bool? isActive,
  //   String? orderBy,
  //   bool ascendingOrder = false,
  // }) async {
  //   await ApiService().getToken();
  //
  //   try {
  //     // 1. تجهيز الفلاتر (Parameters)
  //     Map<String, dynamic> queryParams = {
  //       'PageNumber': page,
  //       'PageSize': limit,
  //       'myProducts': myProducts,
  //       'myFavorites': myFavorites,
  //       'FilterQuery.AscendingOrder': ascendingOrder,
  //     };
  //
  //     // إضافة الفلاتر التي لها قيمة فقط
  //     if (search != null && search.isNotEmpty) queryParams['FilterQuery.Search'] = search;
  //     if (categoryId != null) queryParams['FilterQuery.CategoryId'] = categoryId;
  //     if (subCategoryId != null) queryParams['FilterQuery.SubCategoryId'] = subCategoryId;
  //     if (cityId != null) queryParams['FilterQuery.CityId'] = cityId;
  //     if (minPrice != null) queryParams['FilterQuery.MinPrice'] = minPrice;
  //     if (maxPrice != null) queryParams['FilterQuery.MaxPrice'] = maxPrice;
  //     if (condition != null) queryParams['FilterQuery.Condition'] = condition;
  //     if (isActive != null) queryParams['isActive'] = isActive;
  //     if (orderBy != null && orderBy.isNotEmpty) queryParams['FilterQuery.OrderBy'] = orderBy;
  //
  //     // 2. إرسال الطلب للسيرفر
  //     // تأكد أن المسار 'api/Products' صحيح حسب مشروعك
  //     final response = await ApiService().dio.get(
  //       EndPointsStrings.getProductsEndPoint,
  //       queryParameters: queryParams,
  //     );
  //
  //     // 3. معالجة الاستجابة
  //     if (response.statusCode == 200 && response.data != null) {
  //       var data = response.data;
  //
  //       // التحقق أن البيانات تحتوي على المفتاح "items"
  //       if (data is Map && data['items'] != null) {
  //         List<ProductModel> products = (data['items'] as List)
  //             .map((e) => ProductModel.fromJson(e))
  //             .toList();
  //
  //         return products;
  //       }
  //     }
  //
  //     return []; // إرجاع قائمة فارغة إذا لم تكن هناك بيانات
  //
  //   } on DioException catch (e) {
  //     debugPrint("خطأ شبكة في جلب المنتجات: ${e.message}");
  //     return [];
  //   } catch (e) {
  //     debugPrint("خطأ في معالجة المنتجات: $e");
  //     return [];
  //   }
  // }

  Future<List<ProductModel>> fetchProducts({
    required int page,
    int limit = 5,
    String? search,
    int? categoryId,
    int? subCategoryId,
    int? cityId,
    int? regionId,
    double? minPrice,
    double? maxPrice,
    int? condition,
    bool myProducts = false,
    bool myFavorites = false,
    String? orderBy,
    bool ascendingOrder = false,

    // 🔥 البارامترات الخاصة بلوحة التحكم
    int? adId,
    String? userId,
    bool? isActive,   // 👈 (true: نشط، false: منتهي)
    bool? isBlocked,  // 👈 (true: محظور)
  }) async {
    await ApiService().getToken();

    try {
      Map<String, dynamic> queryParams = {
        'PageNumber': page,
        'PageSize': limit,
        'myProducts': myProducts,
        'myFavorites': myFavorites,
        'FilterQuery.AscendingOrder': ascendingOrder,
      };

      if (search != null && search.isNotEmpty) queryParams['FilterQuery.Search'] = search;
      if (categoryId != null) queryParams['FilterQuery.CategoryId'] = categoryId;
      if (subCategoryId != null) queryParams['FilterQuery.SubCategoryId'] = subCategoryId;
      if (cityId != null) queryParams['FilterQuery.CityId'] = cityId;
      if (regionId != null) queryParams['FilterQuery.RegionId'] = regionId;
      if (minPrice != null) queryParams['FilterQuery.MinPrice'] = minPrice;
      if (maxPrice != null) queryParams['FilterQuery.MaxPrice'] = maxPrice;
      if (condition != null) queryParams['FilterQuery.Condition'] = condition;
      if (orderBy != null && orderBy.isNotEmpty) queryParams['FilterQuery.OrderBy'] = orderBy;

      // 🔥 تمرير الفلاتر الإدارية للسيرفر
      if (adId != null) queryParams['FilterQuery.Id'] = adId;
      if (userId != null) queryParams['FilterQuery.UserId'] = userId;

      // 👈 تمرير قيم الحالة والحظر للسيرفر بناءً على المودل الجديد
      if (isActive != null) queryParams['isActive'] = isActive;
      if (isBlocked != null) queryParams['IsBlocked'] = isBlocked;

      final response = await ApiService().dio.get(
        EndPointsStrings.getProductsEndPoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;
        if (data is Map && data['items'] != null) {
          List<ProductModel> products = (data['items'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
          return products;
        }
      }
      return [];

    } on DioException catch (e) {
      debugPrint("خطأ شبكة في جلب المنتجات: ${e.message}");
      return [];
    } catch (e) {
      debugPrint("خطأ في معالجة المنتجات: $e");
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

  Future<bool> addComment(ProductCommentModel comment) async {
    try {
      await ApiService().getToken();

      final response = await ApiService().dio.post(
        EndPointsStrings.postCommentEndPoint,
        data: {
          'productId': comment.productId,
          'comment': comment.comment,
          'UserId' : comment.userId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(" تم في إضافة التعليق: ${response.statusCode}");
        return true;
      } else {
        debugPrint("فشل في إضافة التعليق: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      debugPrint("خطأ أثناء إضافة التعليق: ${e.message}");
    } catch (e) {
      debugPrint("خطأ غير متوقع أثناء إضافة التعليق: $e");
    }
    return false;
  }

  // دالة جلب المستخدمين للوحة الإدارة
  Future<List<AdminUserModel>> fetchAdminUsers() async {
    try {
      await ApiService().getToken();

      // 👈 استخدام المسار الذي أرسلته
      final response = await ApiService().dio.get('api/Admin/Get');

      if (response.statusCode == 200 && response.data != null) {
        List data = response.data is List ? response.data : response.data['items'] ?? [];
        return data.map((e) => AdminUserModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching users: $e");
      return [];
    }
  }

  Future<bool> updateProduct({
    required int productId,
    required Map<String, dynamic> data,List<File>? images, // أضف هذا الباراميتر
  }) async {
    try {
      FormData formData = FormData.fromMap(data);

      // إضافة الصور الجديدة للـ FormData
      if (images != null) {
        for (var file in images) {
          formData.files.add(MapEntry(
            'NewImages',
            await MultipartFile.fromFile(
              file.path,
            ),
          ));
        }
      }

      debugPrint("FormData for update: ${formData.fields} "
          "with ${formData.files.length} files");
      await ApiService().getToken();
      final response = await ApiService().dio.put(
        '${EndPointsStrings.getProductsEndPoint}/$productId',
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // دالة حظر أو إلغاء حظر المنتج (toggle)
  Future<bool> toggleBlockStatus(int productId) async {
    try {
      await ApiService().getToken();

      // 👈 استخدام المسار الجديد الذي زودتني به
      final response = await ApiService().dio.put(
        'api/Products/$productId/toggle-status-blocked',
      );

      // التحقق من النجاح بناءً على الرد المتوقع
      if (response.statusCode == 200 && response.data != null) {
        // يمكنك طباعة الرسالة القادمة من السيرفر للتأكد
        debugPrint("Server Message: ${response.data['message']}");
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("خطأ أثناء تغيير حالة الحظر: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
      return false;
    }
  }

  Future<bool> toggleChangeActiveStatus(int productId) async {
    try {
      await ApiService().getToken();

      // 👈 استخدام المسار الجديد الذي زودتني به
      final response = await ApiService().dio.put(
        'api/Products/$productId/toggle-status',
      );

      // التحقق من النجاح بناءً على الرد المتوقع
      if (response.statusCode == 200 && response.data != null) {
        // يمكنك طباعة الرسالة القادمة من السيرفر للتأكد
        debugPrint("Server Message: ${response.data['message']}");
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("خطأ أثناء تغيير حالة الحظر: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
      return false;
    }
  }

  // --- دوال إدارة الفئات (Categories Admin) ---
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

  Future<bool> createCategory({required String name, XFile? image}) async {
    try {
      await ApiService().getToken();

      // 1. إنشاء كائن FormData وإضافة البيانات النصية
      FormData formData = FormData.fromMap({
        'name': name, // 👈 تأكد أن الاسم يطابق الـ API (قد يكون Name بحرف كبير)
      });

      // 2. إضافة الصورة إذا تم اختيارها
      if (image != null) {
        formData.files.add(
          MapEntry(
            'image', // 👈 يجب أن يطابق اسم متغير الصورة في الـ API (مثلاً Image أو file)
            // استخدام fromBytes يضمن عمل الرفع بنجاح على الـ Web والموبايل معاً 🚀
            MultipartFile.fromBytes(
              await image.readAsBytes(),
              filename: image.name,
            ),
          ),
        );
      }

      // 3. إرسال الطلب للسيرفر (POST)
      final response = await ApiService().dio.post(
        EndPointsStrings.getCategoriesEndPoint,
        data: formData,
      );

      // 4. التحقق من النجاح
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;

    } on DioException catch (e) {
      debugPrint("خطأ أثناء رفع الفئة: ${e.message}");
      if (e.response != null) {
        debugPrint("تفاصيل الخطأ من السيرفر: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name, XFile? image) async {
    try {
      await ApiService().getToken();

      FormData formData = FormData.fromMap({
        'name': name,
      });

      // نرفق الصورة فقط إذا قام باختيار صورة جديدة لتعديلها
      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(
              await image.readAsBytes(),
              filename: image.name,
            ),
          ),
        );
      }

      final response = await ApiService().dio.put(
        '${EndPointsStrings.getCategoriesEndPoint}/$id',
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 204;

    } catch (e) {
      debugPrint("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.delete('${EndPointsStrings.getCategoriesEndPoint}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error deleting category: $e");
      return false;
    }
  }

  // --- دوال إدارة الفئات الفرعية (SubCategories Admin) ---
  /// جلب الأقسام الفرعية (SubCategories) لقسم معين
  Future<List<SubCategoryModel>> fetchSubCategories(int categoryId) async {
    await ApiService().getToken();

    try {
      // إرسال الـ categoryId كـ Query Parameter أو حسب مسار الـ API لديكم
      // مثال: api/Categories/1/SubCategories أو api/SubCategories?categoryId=1
      final response = await ApiService().dio.get(
        '${EndPointsStrings.getSubCategoriesByCategoryEndPoint}/$categoryId', // أو حسب مسار الـ API عندك
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

  Future<bool> createSubCategory(int categoryId, String name) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.post(
        EndPointsStrings.getSubCategoriesEndPoint,
        data: {'categoryId': categoryId, 'name': name},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error creating subcategory: $e");
      return false;
    }
  }

  Future<bool> updateSubCategory(int subCatId, int categoryId, String name) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.put(
        '${EndPointsStrings.getSubCategoriesEndPoint}/$subCatId',
        data: {'categoryId': categoryId, 'name': name},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error updating subcategory: $e");
      return false;
    }
  }

  Future<bool> deleteSubCategory(int subCatId) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.delete('${EndPointsStrings.getSubCategoriesEndPoint}/$subCatId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error deleting subcategory: $e");
      return false;
    }
  }

  // دالة جلب إحصائيات لوحة التحكم
  Future<AdminStatsModel?> fetchAdminStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await ApiService().getToken();

      // 1. تجهيز المعاملات (Query Parameters)
      Map<String, dynamic> queryParams = {};

      // 2. فحص التواريخ وإضافتها للرابط بصيغة ISO (الصيغة المفضلة لـ .NET)
      if (startDate != null) {
        queryParams['fromDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['toDate'] = endDate;
      }

      // 3. إرسال الطلب مع المعاملات
      final response = await ApiService().dio.get(
        'api/Admin/GetStats/stats',
        queryParameters: queryParams.isNotEmpty ? queryParams : null, // تمرير الفلتر هنا
      );

      if (response.statusCode == 200 && response.data != null) {
        return AdminStatsModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching admin stats: $e");
      return null;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.delete('${EndPointsStrings.getProductsEndPoint}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error deleting subcategory: $e");
      return false;
    }
  }

  Future<bool> refProduct(BuildContext context, int id) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.put('${EndPointsStrings.getProductsEndPoint}/$id/ref');
      if (response.statusCode == 200) {
        debugPrint("تم تحديث الإعلان بنجاح");
        return true;
      } else {
        debugPrint("فشل في تحديث الإعلان: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Error refreshing product: $e");
      return false;
    }
  }
}