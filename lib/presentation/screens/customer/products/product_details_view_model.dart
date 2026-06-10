import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ye_hraj/configurations/resources/strings_manager.dart';
import 'package:ye_hraj/configurations/user_preferences.dart';
import 'package:ye_hraj/model/product_image_model.dart';
import 'package:ye_hraj/model/product_model.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';

import '../../../../model/user_model.dart';
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
  Future<void> addComment(BuildContext context) async {
    if (commentController.text.trim().isEmpty) return;

    String currentUserId = await UserPreferences().getString(
      key: AppStrings.userIdKey,
      defaultValue: '',
    );
    String currentUserName = await UserPreferences().getString(
      key: AppStrings.userNameKey,
      defaultValue: '',
    );
    String currentUserImageUrl = await UserPreferences().getString(
      key: AppStrings.userProfileImageUrlKey,
      defaultValue: '',
    );
    String currentUserEmail = await UserPreferences().getString(
      key: AppStrings.userEmailKey,
      defaultValue: '',
    );
    // محاكاة إضافة تعليق (في الواقع ترسل للسيرفر)
    final newComment = ProductCommentModel(
      id: 1,
      comment: commentController.text,
      productId: _productDetails?.id ?? 0,
      user: UserModel(
        id: currentUserId,
        fullName: currentUserName,
        email: currentUserEmail,
        profileImageUrl: currentUserImageUrl,
      ),
      userId: currentUserId,
    );

    // إضافة للقائمة وتحديث الواجهة
    bool isDone = await _repo.addComment(
      newComment,
    ); // يمكنك تعديل هذا ليضيف التعليق فعلياً للسيرفر ثم يعيد جلب التعليقات
    if (isDone) {
      _productDetails?.comments.add(newComment);
      commentController.clear();
      _commentCharCount = 0;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(title: 'تم إضافة التعليق بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            title: 'حدث خطأ أثناء إضافة التعليق. حاول مرة أخرى.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> startChatWithSeller(
    BuildContext context,
    ProductModel product,
  ) async {
    // 1. جلب بيانات المستخدم الحالي (أنت) من الذاكرة المحلية
    String currentUserId = await UserPreferences().getString(
      key: AppStrings.userIdKey,
      defaultValue: '',
    );

    // تحقق مبدئي: إذا لم يكن مسجل دخول، وجهه لصفحة تسجيل الدخول
    if (currentUserId.isEmpty) {
      // Navigator.pushNamed(context, '/login');
      return;
    }

    String senderName = await UserPreferences().getString(
      key: AppStrings.userNameKey,
      defaultValue: 'مستخدم',
    );
    String senderImagePrfile = await UserPreferences().getString(
      key: 'senderImagePrfile',
      defaultValue: '',
    );

    // ⚠️ خطوة مهمة جداً: التأكد أن الشاشة لا تزال مفتوحة بعد الـ await
    if (!context.mounted) return;

    // تحديد آيدي البائع (نبحث في userId المباشر أولاً، ثم داخل كائن user)
    String sellerId = product.user?.id ?? '0';

    debugPrint("Current User ID: $currentUserId, Seller ID: $sellerId");

    // 2. تحقق أن المستخدم لا يراسل نفسه
    if (currentUserId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكنك مراسلة نفسك!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // محاولة جلب صورة البائع من الموديل (إذا كانت متوفرة)
    String sellerImage = '';
    if (product.user != null && product.user!.profileImageUrl != null) {
      sellerImage = product.user!.profileImageUrl!;
    }

    // 3. الانتقال للشات مع تمرير البيانات الحقيقية للطرفين + المنتج
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          // بياناتي أنا (التي جلبناها من الـ Preferences)
          currentUserId: currentUserId,
          senderName: senderName,
          senderProfileImageUrl: senderImagePrfile,

          // بيانات البائع (التي جلبناها من الإعلان)
          otherUserId: sellerId,
          otherUserName: product.user?.fullName ?? 'صاحب الإعلان',
          otherUserImageUrl: sellerImage,
          // 👈 تمرير صورة البائع إن وجدت

          // سياق المحادثة (المنتج)
          productContext: product,
        ),
      ),
    );
  }

// داخل كلاس ProductDetailsViewModel
  void shareProduct(BuildContext context, ProductModel product) async {

    final String appLink = "https://play.google.com/store/apps/details?id=com.alamodi_dev.ye_hraj";
    final String message = "شاهد هذا الإعلان: ${product.title}\nحمل التطبيق من هنا: $appLink";

    try {
      // 3. استدعاء نافذة المشاركة
      await Share.share(
        message,
        subject: product.title, // موضوع الرسالة (يظهر في الإيميل مثلاً)
      );
    } catch (e) {
      debugPrint("Error sharing product: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء محاولة المشاركة')),
        );
      }
    }
  }


  void shareProduct2(BuildContext context, ProductModel product) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة المشاركة قيد التطوير!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

}