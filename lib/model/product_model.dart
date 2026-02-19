import 'package:ye_hraj/model/product_image_model.dart';

import 'category_model.dart';
import 'product_condition.dart';
import 'user_model.dart';

class ProductModel {
  final int id;
  final String title;
  final String status;
  final String description;
  final double? price; // C# Decimal -> Dart double
  final ProductCondition condition;

  // إعدادات التواصل
  final bool allowChat;
  final bool allowCall;
  final bool allowWhatsApp;
  final bool showPhoneNumber;

  final int viewsCount;
  final DateTime createdAt;

  // العلاقات (IDs & Objects)
  final String userId;
  final UserModel? user;

  final int categoryId;
  final CategoryModel? category;

  final int subCategoryId;
  final SubCategoryModel? subCategory;

  final int cityId;
  final CityModel? city;

  final int regionId;
  final RegionModel? region;

  // القوائم
  final List<ProductImageModel> images;
  final List<ProductCommentModel> comments;

  // ✅ الحقل الجديد: الخصائص
  // final Map<String, String> attributes;

  ProductModel({
    required this.id,
    required this.title,
    required this.status,
    required this.description,
    this.price,
    required this.condition,
    this.allowChat = true,
    this.allowCall = true,
    this.allowWhatsApp = false,
    this.showPhoneNumber = true,
    this.viewsCount = 0,
    required this.createdAt,
    required this.userId,
    this.user,
    required this.categoryId,
    this.category,
    required this.subCategoryId,
    this.subCategory,
    required this.cityId,
    this.city,
    required this.regionId,
    this.region,
    this.images = const [],
    this.comments = const [],
    // this.attributes = const {}, // قيمة افتراضية فارغة
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      // تحويل آمن للسعر (يقبل int أو double من الـ API)
      price: (json['price'] as num?)?.toDouble(),
      // تحويل الرقم إلى Enum
      condition: ProductConditionHelper.fromInt(json['condition'] ?? 2),

      allowChat: json['allowChat'] ?? true,
      allowCall: json['allowCall'] ?? true,
      allowWhatsApp: json['allowWhatsApp'] ?? false,
      showPhoneNumber: json['showPhoneNumber'] ?? true,
      viewsCount: json['viewsCount'] ?? 0,

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),

      userId: json['userId'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,

      categoryId: json['categoryId'] ?? 0,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,

      subCategoryId: json['subCategoryId'] ?? 0,
      subCategory: json['subCategory'] != null ? SubCategoryModel.fromJson(json['subCategory']) : null,

      cityId: json['cityId'] ?? 0,
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,

      regionId: json['regionId'] ?? 0,
      region: json['region'] != null ? RegionModel.fromJson(json['region']) : null,

      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImageModel.fromJson(e))
          .toList() ?? [],

      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => ProductCommentModel.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'status': status,
    'description': description,
    'price': price,
    'condition': ProductConditionHelper.toInt(condition),
    'allowChat': allowChat,
    'allowCall': allowCall,
    'allowWhatsApp': allowWhatsApp,
    'showPhoneNumber': showPhoneNumber,
    'viewsCount': viewsCount,
    'createdAt': createdAt.toIso8601String(),
    'userId': userId,
    'user': user?.toJson(),
    'categoryId': categoryId,
    'category': category?.toJson(),
    'subCategoryId': subCategoryId,
    'subCategory': subCategory?.toJson(),
    'cityId': cityId,
    'city': city?.toJson(),
    'regionId': regionId,
    'region': region?.toJson(),
    'images': images.map((e) => e.toJson()).toList(),
    'comments': comments.map((e) => e.toJson()).toList(),
  };

  // ✅✅✅ هنا الإضافة الذكية: Getter ينشئ الخصائص ديناميكياً ✅✅✅
  Map<String, String> get attributes {
    return {
      'رقم الإعلان': '$id',
      if (subCategory != null) 'القسم': subCategory!.name,
      'الحالة': condition == ProductCondition.newItem ? 'جديد' : 'مستعمل',
      if (city != null && region != null) 'الموقع': '${city!.name} - ${region!.name}',
      if (price != null) 'السعر': '$price ر.ي',
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