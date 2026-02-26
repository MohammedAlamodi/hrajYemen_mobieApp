import 'package:ye_hraj/model/user_model.dart';

import '../configurations/data/end_points_manager.dart';

class ProductImageModel {
  final int id;
  final String imageUrl;
  final bool isMain;
  final int? productId; // قد لا يأتي من القائمة المختصرة

  ProductImageModel({
    required this.id,
    required this.imageUrl,
    required this.isMain,
    this.productId,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    String path = json['imageUrl'] ?? '';
    if (path.startsWith('/')) {
      path = '${EndPointsStrings.baseUrl}$path';
    }

    return ProductImageModel(
      id: json['id'] ?? 0,
      imageUrl: path,
      isMain: json['isMain'] ?? false,
      productId: json['productId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // إعادة المسار لشكله الأصلي (بدون الدومين) إذا كنت سترسله للباك إند
      'imageUrl': imageUrl.replaceAll('https://hrajyemen-001-site1.site4future.com', ''),
      'isMain': isMain,
      if (productId != null) 'productId': productId,
    };
  }
}

class ProductCommentModel {
  final int id;
  final String comment;
  final int productId;
  final String userId;
  final UserModel? user; // قد نحتاج بيانات المستخدم لعرض صورته واسمه
  final DateTime? createdAt;

  ProductCommentModel({
    required this.id,
    required this.comment,
    // required this.userName,
    required this.productId,
    // required this.userImage,
    required this.userId,
    this.user,
    this.createdAt,
  });

  factory ProductCommentModel.fromJson(Map<String, dynamic> json) {
    return ProductCommentModel(
      id: json['id'] ?? 0,
      comment: json['comment'] ?? '',
      // userName: json['userName'] ?? '',
      // userImage: json['userImage'] ?? '',
      productId: json['productId'] ?? 0,
      userId: json['userId'] ?? '',
      user: UserModel.fromJson(json['user']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'comment': comment,
    'productId': productId,
    // 'userName': userName,
    // 'userImage': userImage,
    'userId': userId,
    'user': user?.toJson(),
    'createdAt': createdAt?.toIso8601String(),
  };
}