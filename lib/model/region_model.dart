
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