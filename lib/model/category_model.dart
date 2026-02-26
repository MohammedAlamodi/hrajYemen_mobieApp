import 'package:flutter/material.dart';

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
      imageUrl: json['imageUrl'], // قد يكون null
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => SubCategoryModel.fromJson(e))
          .toList() ?? [],
    );
  }
}