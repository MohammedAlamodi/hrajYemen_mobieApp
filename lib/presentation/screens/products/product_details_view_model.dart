import 'package:flutter/material.dart';
// import 'url_launcher/url_launcher.dart'; // ستحتاج هذه المكتبة للاتصال الفعلي

// view_model/product_details_view_model.dart

import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';
import 'package:ye_hraj/model/product_image_model.dart';
import 'package:ye_hraj/model/product_model.dart';

import '../../../model/seller_model.dart';
import '../../../model/user_model.dart';
import '../chat/chat_screen.dart';
import '../home/home_repo.dart';

class ProductDetailsViewModel extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  final TextEditingController commentController = TextEditingController();

  ProductModel? _productDetails;
  bool _isLoading = true; // يبدأ بالتحميل مباشرة
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;

  int _commentCharCount = 0;
  int get commentCharCount => _commentCharCount;

  // Getters
  ProductModel? get productDetails => _productDetails;
  bool get isLoading => _isLoading;
  int get currentImageIndex => _currentImageIndex;
  bool get isDescriptionExpanded => _isDescriptionExpanded;

  // جلب التفاصيل
  Future<void> loadProductDetails(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _productDetails = await _repo.fetchProductDetails(productId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print("Error loading details: $e");
    }
  }

  void onPageChanged(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void toggleDescription() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  // دالة تحديث العداد عند الكتابة
  void updateCommentCount(String value) {
    _commentCharCount = value.length;
    notifyListeners();
  }

  // 3. دالة إضافة التعليق
  void addComment() {
    if (commentController.text.trim().isEmpty) return;

    // محاكاة إضافة تعليق (في الواقع ترسل للسيرفر)
    final newComment = ProductCommentModel(
      id: 1,
      comment: commentController.text,
      productId: _productDetails?.id ?? 0,
      userId: EndPointsStrings.userIdConst,
      user: UserModel(
        id: EndPointsStrings.userIdConst.toString(),
        fullName: "أنا المستخدم",
        profileImageUrl: 'https://placehold.co/80x80?text=S'
      ),
    );

    // إضافة للقائمة وتحديث الواجهة
    _productDetails?.comments.add(newComment);

    // تنظيف الحقل
    commentController.clear();
    _commentCharCount = 0;

    notifyListeners();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // دالة الانتقال للشات
  void startChatWithSeller(BuildContext context, ProductModel product) {
    // 1. تحقق أن المستخدم مسجل دخول
    // if (currentUserId == null) { goToLogin(); return; }

    // 2. تحقق أن المستخدم لا يراسل نفسه
    if (EndPointsStrings.userIdConst == product.user?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكنك مراسلة نفسك!')),
      );
      return;
    }

    // 3. الانتقال للشات مع تمرير "المنتج"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          currentUserId: EndPointsStrings.userIdConst,   // آيدي المستخدم الحالي (أنا)
          otherUserId: product.user!.id,  // آيدي البائع (صاحب الإعلان)
          otherUserName: product.user?.fullName ?? '', // اسم البائع (للعرض في الهيدر)

          // 🔥🔥🔥 السحر هنا 🔥🔥🔥
          // تمرير المنتج هو ما سيجعل الكارد يظهر فوق الشات
          productContext: product,
        ),
      ),
    );
  }
}

// class ProductDetailsViewModel extends ChangeNotifier {
//   int _currentImageIndex = 0;
//   bool _isDescriptionExpanded = false;
//
//   int get currentImageIndex => _currentImageIndex;
//   bool get isDescriptionExpanded => _isDescriptionExpanded;
//
//   void onPageChanged(int index) {
//     _currentImageIndex = index;
//     notifyListeners();
//   }
//
//   void toggleDescription() {
//     _isDescriptionExpanded = !_isDescriptionExpanded;
//     notifyListeners();
//   }
//
//   // دوال الاتصال والمراسلة (Logic)
//   void makeCall() {
//     // launchUrl(Uri.parse("tel:+967700000000"));
//     print("Connecting to call...");
//   }
//
//   void openWhatsApp() {
//     print("Opening WhatsApp...");
//   }
//
//   void navigateToChat(BuildContext context) {
//     // Navigator.push Named...
//     print("Navigate to internal chat");
//   }
// }