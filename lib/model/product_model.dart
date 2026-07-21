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
  final String? priceCurrency;
  final String? regionName;
  final String? userName;
  final UserModel? user;
  final String? userProfileImageUrl;

  final int? categoryId;
  final int? subCategoryId;
  final int? cityId;
  final int? regionId;

  final bool isActive;
  final bool isBlocked;
  final bool isFavorite;
  final bool allowCall; // هل يسمح المالك بالاتصال؟
  final bool allowChat; // هل يسمح المالك بالمراسلة؟
  final String? mainImageUrl;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updateAt;

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
    this.priceCurrency,
    this.user,
    this.userProfileImageUrl,
    this.cityId,
    this.categoryId,
    this.subCategoryId,
    this.regionId,
    // required this.userId,

    required this.isBlocked,
    required this.isActive,
    required this.isFavorite,
    this.allowCall = true,
    this.allowChat = true,
    this.mainImageUrl,
    required this.viewsCount,
    required this.createdAt,
    required this.updateAt,

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
      priceCurrency: json['priceCurrency'] ?? 'RY',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble(),
      condition: json['condition'],
      userProfileImageUrl: json['userImageUrl'],
      categoryName: json['categoryName'],
      subCategoryName: json['subCategoryName'],
      cityName: json['cityName'],
      regionName: json['regionName'],
      userName: json['userName'],
      regionId: json['regionId'],
      categoryId: json['categoryId'],
      subCategoryId: json['subCategoryId'],
      cityId: json['cityId'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,

      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      allowCall: json['allowCall'] ?? true,
      allowChat: json['allowChat'] ?? true,
      mainImageUrl: mainImage,
      viewsCount: json['viewsCount'] ?? 0,

      createdAt: parseServerDateTime(json['createdAt']),

      updateAt: parseServerDateTime(json['updateAt']),
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
      'priceCurrency': priceCurrency,
      'subCategoryName': subCategoryName,
      'cityName': cityName,
      'regionName': regionName,
      'userName': userName,

      'isActive': isActive,
      'isBlocked': isBlocked,
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

  /// تسلسل كامل (غير ناقص) مخصّص للتخزين في الكاش.
  /// يستخدم نفس مفاتيح [fromJson] ليتم استرجاع الكائن بنفس حالته تماماً
  /// (على عكس [toJson] المخصّص للإرسال للسيرفر والذي يحذف بعض الحقول).
  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'condition': condition,
      'priceCurrency': priceCurrency,
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'cityName': cityName,
      'regionName': regionName,
      'userName': userName,
      'userImageUrl': userProfileImageUrl,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'cityId': cityId,
      'regionId': regionId,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'isFavorite': isFavorite,
      'allowCall': allowCall,
      'allowChat': allowChat,
      // نخزّن الرابط الكامل كما هو؛ لن يضيف fromJson الدومين لأنه لا يبدأ بـ '/'
      'mainImageUrl': mainImageUrl,
      'viewsCount': viewsCount,
      // نخزّن بتوقيت UTC (بعلامة Z) ليُسترجع بشكل صحيح من الكاش
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updateAt': updateAt.toUtc().toIso8601String(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  // توليد الخصائص للواجهة بناءً على البيانات القادمة
  Map<String, String> get attributes {
    return {
      'رقم الإعلان': '$id',
      if (categoryName != null) 'الفئة': categoryName!,
      if (subCategoryName != null) 'القسم': subCategoryName!,
      if (condition != null)
        'الحالة': condition == "1" ? 'جديد' : 'مستعمل',
      if (cityName != null && regionName == null) 'الموقع': cityName!,
      if (price != null && price! > 0)
        'السعر': '${price!.toStringAsFixed(0)} ر.ي',
      'تاريخ النشر': formatTimeAgo(createdAt),
    };
  }
}

/// تحويل تاريخ السيرفر إلى وقت محلي صحيح.
/// السيرفر يرسل الوقت بتوقيت UTC لكن بدون علامة منطقة زمنية،
/// فيفسّره Dart كتوقيت محلي (فيظهر فرق ثابت = فرق التوقيت، مثلاً 3 ساعات).
/// الحل: نعيد تفسيره كـ UTC ثم نحوّله للتوقيت المحلي.
DateTime parseServerDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    final String str = value.toString();
    DateTime dt = DateTime.parse(str);

    final bool hasTimeZone =
        str.endsWith('Z') || RegExp(r'[+\-]\d{2}:?\d{2}$').hasMatch(str);

    if (!dt.isUtc && !hasTimeZone) {
      dt = DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute,
          dt.second, dt.millisecond, dt.microsecond);
    }
    return dt.toLocal();
  } catch (_) {
    return DateTime.now();
  }
}

// دالة مساعدة لتنسيق التاريخ (يمكنك وضعها في ملف util خارجي)
String formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays == 0) {
    if (diff.inHours == 0) {
      if (diff.inMinutes <= 0) return 'الآن';
      return 'منذ ${diff.inMinutes} دقيقة';
    }
    return 'منذ ${diff.inHours} ساعة';
  } else if (diff.inDays <= 7) {
    return 'منذ ${diff.inDays} أيام';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
