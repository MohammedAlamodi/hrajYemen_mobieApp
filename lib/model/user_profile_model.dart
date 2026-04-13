
import 'package:ye_hraj/configurations/data/end_points_manager.dart';

class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? bio;
  final int? regionId;
  final String? region;
  final int? cityId;
  final String? city;
  final DateTime createdAt;
  final int numberOfProducts;
  final int numberOfExpireProducts;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.regionId,
    this.region,
    this.city,
    this.cityId,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.numberOfProducts,
    required this.numberOfExpireProducts,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // إصلاح رابط الصورة إذا كان يبدأ بـ /
    String? imageUrl = json['profileImageUrl'];
    if (imageUrl != null && (imageUrl.startsWith('/') || imageUrl.startsWith('images'))) {
      imageUrl = '${EndPointsStrings.baseUrl}$imageUrl'; // ضع الدومين الخاص بك
    }

    return UserProfileModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'مستخدم',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: imageUrl,
      bio: json['bio'],
      regionId: json['regionId'],
      region: json['regionName'] ?? 'غير محدد',
      city: json['cityName'] ?? 'غير محدد',
      cityId: json['cityId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      numberOfProducts: json['numberOfProducts'] ?? 0,
      numberOfExpireProducts: json['numberOfExpireProducts'] ?? 0,
    );
  }
}