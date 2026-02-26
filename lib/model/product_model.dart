import 'package:ye_hraj/configurations/data/end_points_manager.dart';
import 'package:ye_hraj/model/product_image_model.dart';
import 'package:ye_hraj/model/user_model.dart';

import 'product_condition.dart';

class ProductModel {
  final int id;
  final String title;
  final String? description;
  final double? price;
  final String? condition;

  final String? categoryName;
  final String? subCategoryName;
  final String? cityName;
  final String? regionName;
  final String? userName;
  // final String userId;
  final UserModel? user;
  final String? userProfileImageUrl;
  // final UserModel? user;

  final bool isActive;
  final bool isFavorite;
  final String? mainImageUrl;
  final int viewsCount;
  final DateTime createdAt;

  final List<ProductImageModel> images;

  final List<ProductCommentModel> comments;

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    this.price,
    this.condition,

    this.categoryName,
    this.subCategoryName,
    this.cityName,
    this.regionName,
    this.userName,
    this.user,
    this.userProfileImageUrl,
    // required this.userId,

    required this.isActive,
    required this.isFavorite,
    this.mainImageUrl,
    required this.viewsCount,
    required this.createdAt,

    this.images = const [],
    this.comments = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 1. معالجة مصفوفة الصور
    List<ProductImageModel> parsedImages = [];
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      parsedImages = (json['images'] as List)
          .map((e) => ProductImageModel.fromJson(e))
          .toList();
    }
    // إذا كانت مصفوفة الصور فارغة لكن يوجد mainImageUrl (كحل احتياطي)
    else if (json['mainImageUrl'] != null) {
      String path = json['mainImageUrl'];
      if (path.startsWith('/')) {
        path = '${EndPointsStrings.baseUrl}$path';
      }
      parsedImages.add(ProductImageModel(id: 0, imageUrl: path, isMain: true));
    }

    // 2. إصلاح رابط الصورة الرئيسية
    String? mainImage = json['mainImageUrl'];
    if (mainImage != null && mainImage.startsWith('/')) {
      mainImage = '${EndPointsStrings.baseUrl}$mainImage';
    }

    return ProductModel(
      id: json['id'] ?? 0,
      // userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble(),
      condition: json['condition'],
      userProfileImageUrl: json['userImageUrl'],
      categoryName: json['categoryName'],
      subCategoryName: json['subCategoryName'],
      cityName: json['cityName'],
      regionName: json['regionName'],
      userName: json['userName'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,

      isActive: json['isActive'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      mainImageUrl: mainImage,
      viewsCount: json['viewsCount'] ?? 0,

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      images: parsedImages,
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => ProductCommentModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      // تحويل حالة المنتج (Enum) إلى رقم (1 أو 2) كما يتوقع السيرفر
      'condition': condition,

      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'cityName': cityName,
      'regionName': regionName,
      'userName': userName,

      'isActive': isActive,
      'isFavorite': isFavorite,

      // إزالة الدومين عند الإرسال للسيرفر إذا كان السيرفر يحفظ المسار فقط (مثل /images/...)
      'mainImageUrl': mainImageUrl?.replaceAll('https://hrajyemen-001-site1.site4future.com', ''),

      'viewsCount': viewsCount,
      'createdAt': createdAt.toIso8601String(), // تحويل التاريخ لنص قياسي

      // تحويل مصفوفة الصور والتعليقات
      'images': images.map((e) => e.toJson()).toList(),
      // 'comments': comments.map((e) => e.toJson()).toList(), // إذا كان لديك تعليقات
    };
  }

  // توليد الخصائص للواجهة بناءً على البيانات القادمة
  Map<String, String> get attributes {
    return {
      'رقم الإعلان': '$id',
      if (categoryName != null) 'الفئة': categoryName!,
      if (subCategoryName != null) 'القسم': subCategoryName!,
      if (condition != null)
        'الحالة': condition == "New" ? 'جديد' : 'مستعمل',
      if (cityName != null && regionName == null) 'الموقع': cityName!,
      if (price != null && price! > 0)
        'السعر': '${price!.toStringAsFixed(0)} ر.ي',
      'تاريخ النشر': formatTimeAgo(createdAt),
    };
  }
}

// دالة مساعدة لتنسيق التاريخ (يمكنك وضعها في ملف util خارجي)
String formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays == 0) {
    if (diff.inHours == 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'منذ ${diff.inHours} ساعة';
  } else if (diff.inDays <= 7) {
    return 'منذ ${diff.inDays} أيام';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
