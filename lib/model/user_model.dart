class UserModel {
  final String id;
  final String? fullName;
  final String? userName;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? bio;
  final String? location;
  final int? activeAdsCount;
  final int? expiredAdsCount;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    this.fullName,
    this.userName,
    this.email,
    this.location,
    this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    this.createdAt,
    this.activeAdsCount,
    this.expiredAdsCount
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'],
      userName: json['userName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      location: json['location'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'userName': userName,
    'email': email,
    'location': location,
    'phoneNumber': phoneNumber,
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'createdAt': createdAt?.toIso8601String(),
  };
}