// models/seller_model.dart
class SellerModel {
  final int id;
  final String name;
  final String imageUrl;
  final String role; // مثلاً: بائع موثوق

  SellerModel({required this.id, required this.name, required this.imageUrl, this.role = 'بائع'});
}

// models/comment_model.dart
// class CommentModel {
//   final String userName;
//   final String userImage;
//   final String content;
//   final String timeAgo;
//
//   CommentModel({required this.userName, required this.userImage, required this.content, required this.timeAgo});
// }

// تحديث بسيط لـ ProductDetailsModel ليشمل التفاصيل الدقيقة
// class ProductDetailsModel {
//   final String id;
//   final List<String> images;
//   final String price;
//   final String title;
//   final String location;
//   final String date;
//   final String description;
//   final Map<String, String> attributes; // مثلا: {'الفئة': 'جوالات', 'الحالة': 'جديد'}
//   final SellerModel seller;
//   final List<CommentModel> comments;
//
//   ProductDetailsModel({
//     required this.id,
//     required this.images,
//     required this.price,
//     required this.title,
//     required this.location,
//     required this.date,
//     required this.description,
//     required this.attributes,
//     required this.seller,
//     required this.comments,
//   });
// }