import 'dart:convert';

class DynamicItemModel {
  final String id;
  final String title;
  final String imageUrl;
  final String phoneNumber;

  DynamicItemModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.phoneNumber,
  });

  // فايربيس
  factory DynamicItemModel.fromMap(Map<String, dynamic> map, String id) {
    return DynamicItemModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  // للحفظ Local (Json)
  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'imageUrl': imageUrl, 'phoneNumber': phoneNumber
  };

  factory DynamicItemModel.fromJson(Map<String, dynamic> json) => DynamicItemModel(
      id: json['id'], title: json['title'], imageUrl: json['imageUrl'], phoneNumber: json['phoneNumber']
  );
}