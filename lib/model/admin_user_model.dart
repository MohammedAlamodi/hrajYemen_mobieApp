class AdminUserModel {
  final String id;
  final String? fullName;
  final String? userName;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? bio;
  final String? createdAt;
  final String? cityName;
  final String? regionName;
  final int numberOfProducts;
  final int numberOfExpireProducts;
  bool lockoutEnabled;
  bool isBlocked;
  final int userType;

  AdminUserModel({
    required this.id,
    this.fullName,
    this.userName,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    this.createdAt,
    this.cityName,
    this.regionName,
    required this.isBlocked,
    required this.numberOfProducts,
    required this.numberOfExpireProducts,
    required this.lockoutEnabled,
    required this.userType,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'],
      userName: json['userName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      createdAt: json['createdAt'],
      isBlocked: json['isBlocked'],
      cityName: json['cityName'],
      regionName: json['regionName'],
      numberOfProducts: json['numberOfProducts'] ?? 0,
      numberOfExpireProducts: json['numberOfExpireProducts'] ?? 0,
      lockoutEnabled: json['lockoutEnabled'] ?? false,
      userType: json['userType'] ?? 1,
    );
  }

  // دالة مساعدة للحصول على اسم العرض الأنسب
  String get displayName => fullName ?? userName ?? email ?? 'مستخدم غير معروف';
}