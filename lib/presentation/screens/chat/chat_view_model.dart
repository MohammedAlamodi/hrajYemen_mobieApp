import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../model/message_model.dart';
import '../../../model/product_model.dart';
import '../../../model/seller_model.dart';
import 'chat_repo.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();
  final TextEditingController msgController = TextEditingController();

  final String currentUserId;
  final String senderProfileImageUrl;
  final String senderName;
  final String otherUserId;
  late String chatRoomId;

  // المنتج المرفق (Context)
  Map<String, dynamic>? _attachedProductData;
  bool _showProductPreview = false;

  bool get showProductPreview => _showProductPreview;
  Map<String, dynamic>? get attachedProductData => _attachedProductData;
  final String otherUserName;      // أضف هذا
  final String otherUserImageUrl;

  ChatViewModel({
    required this.currentUserId,
    required this.senderProfileImageUrl,
    required this.senderName,
    required this.otherUserId,
    required this.otherUserName,      // أضف هذا
    required this.otherUserImageUrl,
    ProductModel? productContext, // نستقبل المنتج هنا
  }) {
    chatRoomId = _repo.getChatRoomId(currentUserId, otherUserId);

    // إذا جينا من صفحة منتج، نجهز البيانات
    if (productContext != null) {
      _attachedProductData = {
        'id': productContext.id,
        'title': productContext.title,
        'price': productContext.price,
        'image': productContext.images.isNotEmpty ? productContext.images.first.imageUrl : '',
        'ref': productContext.id // مرجع للإعلان
      };
      _showProductPreview = true; // إظهار الكارد فوق مربع النص
    }
  }

  // إرسال رسالة (نصية أو مرفق معها منتج)
  Future<void> sendMessage() async {
    final text = msgController.text.trim();
    // نمنع الإرسال اذا فاضي، إلا لو فيه منتج مرفق
    if (text.isEmpty && !_showProductPreview) return;

    try {
      final msg = MessageModel(
        senderId: currentUserId,
        senderName: senderName,
        senderProfileImageUrl: senderProfileImageUrl,
        receiverId: otherUserId,
        text: text, // قد يكون فارغاً إذا أرسل المنتج فقط
        type: _showProductPreview ? 'product' : 'text', // نوع الرسالة
        productData: _showProductPreview ? _attachedProductData : null,
        timestamp: DateTime.now(),
      );

      await _repo.sendMessage(chatRoomId: chatRoomId,
        message: msg,
        receiverName: otherUserName,
        receiverImageUrl: otherUserImageUrl,);

      // تنظيف
      msgController.clear();
      if (_showProductPreview) {
        _showProductPreview = false; // نخفي الكارد بعد الإرسال
        _attachedProductData = null;
        notifyListeners();
      }
    } catch (e) {
      print("Error sending message: $e");
      // هنا ممكن تظهر سناك بار في الـ View
    }
  }

  // إرسال صورة من المعرض
  Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        String url = await _repo.uploadImage(File(pickedFile.path));
        final msg = MessageModel(
          senderId: currentUserId,
          senderName: senderName,
          senderProfileImageUrl: senderProfileImageUrl,
          receiverId: otherUserId,
          imageUrl: url,
          type: 'image',
          timestamp: DateTime.now(),
        );
        await _repo.sendMessage(chatRoomId: chatRoomId,
          message: msg,
          receiverName: otherUserName,
          receiverImageUrl: otherUserImageUrl,);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  // إغلاق معاينة المنتج (اذا المستخدم بطل يرسله)
  void closeProductPreview() {
    _showProductPreview = false;
    _attachedProductData = null;
    notifyListeners();
  }

  Stream get messagesStream => _repo.getMessages(chatRoomId);
}