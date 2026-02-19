// City & Region
import 'package:flutter/material.dart';

class RegionModel {
  final int id;
  final String name;
  final int cityId;

  RegionModel({required this.id, required this.name, required this.cityId});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      cityId: json['cityId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cityId': cityId,
  };
}

class CityModel {
  final int id;
  final String name;
  final List<RegionModel> regions;

  CityModel({required this.id, required this.name, this.regions = const []});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      regions: (json['regions'] as List<dynamic>?)
          ?.map((e) => RegionModel.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'regions': regions.map((e) => e.toJson()).toList(),
  };
}

// Category & SubCategory
class SubCategoryModel {
  final int id;
  final String name;
  final int categoryId;

  SubCategoryModel({required this.id, required this.name, required this.categoryId});

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
  };
}

class CategoryModel {
  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final List<SubCategoryModel> subCategories;

  CategoryModel({required this.id,required this.icon,required this.color, required this.name, this.subCategories = const []});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => SubCategoryModel.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subCategories': subCategories.map((e) => e.toJson()).toList(),
  };
}