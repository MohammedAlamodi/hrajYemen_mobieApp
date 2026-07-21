import 'package:flutter/material.dart';

import '../configurations/data/end_points_manager.dart';

class SubCategoryModel {
  final int id;
  final String name;

  SubCategoryModel({required this.id, required this.name});

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String? imageUrl; // 👈 تعديل: أصبح يقبل null حسب الـ API
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.subCategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      // تحويل المسار النسبي القادم من السيرفر إلى رابط كامل
      imageUrl: _buildFullImageUrl(json['imageUrl']),
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => SubCategoryModel.fromJson(e))
          .toList() ?? [],
    );
  }

  /// يحوّل مسار الصورة (مثل "images/categories/x.png") إلى رابط كامل.
  /// يُعيد null إذا لم توجد صورة، ويُبقي الرابط كما هو إذا كان كاملاً أصلاً.
  static String? _buildFullImageUrl(dynamic rawPath) {
    if (rawPath == null) return null;
    final path = rawPath.toString().trim();
    if (path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // baseUrl ينتهي بـ '/'، لذا نزيل أي '/' بادئ من المسار لتفادي التكرار
    final base = EndPointsStrings.baseUrl;
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    return '$base$cleaned';
  }
}