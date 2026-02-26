import 'region_model.dart';

class CitiesModel {
  final int id;
  final String name;
  final List<RegionModel> regions;

  CitiesModel({required this.id, required this.name, this.regions = const []});

  factory CitiesModel.fromJson(Map<String, dynamic> json) {
    return CitiesModel(
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