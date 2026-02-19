import 'package:ye_hraj/model/user_model.dart';

class ProductImageModel {
  final int id;
  final String imageUrl;
  final bool isMain;
  final int productId;

  ProductImageModel({
    required this.id,
    required this.imageUrl,
    required this.isMain,
    required this.productId,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isMain: json['isMain'] ?? false,
      productId: json['productId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'isMain': isMain,
    'productId': productId,
  };
}

class ProductCommentModel {
  final int id;
  final String comment;
  final int productId;
  final String userId;
  final UserModel user; // قد نحتاج بيانات المستخدم لعرض صورته واسمه
  final DateTime? createdAt;

  ProductCommentModel({
    required this.id,
    required this.comment,
    // required this.userName,
    required this.productId,
    // required this.userImage,
    required this.userId,
    required this.user,
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