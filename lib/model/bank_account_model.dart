import 'dart:convert';

import '../configurations/data/end_points_manager.dart';

class BankAccountModel {
  final int? id;
  final String name;
  final String accountNumber;
  final String? imageUrl;

  BankAccountModel({
    this.id,
    required this.name,
    required this.accountNumber,
    this.imageUrl,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    String? mainImage = json['imageUrl'];
    if (mainImage != null && mainImage.startsWith('images/')) {
      mainImage = '${EndPointsStrings.baseUrl}$mainImage';
    }

    return BankAccountModel(
      id: json['id'],
      name: json['name'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      imageUrl: mainImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'accountNumber': accountNumber,
      'imageUrl': imageUrl ?? '',
    };
  }

  // لتحويل القائمة إلى نص لحفظها محلياً في الموبايل
  static String encode(List<BankAccountModel> accounts) => json.encode(
    accounts.map<Map<String, dynamic>>((account) => account.toJson()).toList(),
  );

  // لفك النص إلى قائمة عند القراءة من التخزين المحلي
  static List<BankAccountModel> decode(String accountsStr) =>
      (json.decode(accountsStr) as List<dynamic>)
          .map<BankAccountModel>((item) => BankAccountModel.fromJson(item))
          .toList();
}