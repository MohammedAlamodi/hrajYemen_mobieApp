import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../../model/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // توليد ID موحد للغرفة
  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }

  // إرسال الرسالة
  Future<void> sendMessage({
    required String chatRoomId,
    required MessageModel message,
    required String receiverName,       // إضافة اسم المستلم
    required String receiverImageUrl,   // إضافة صورة المستلم
  }) async {
    try {
      // 1. إضافة الرسالة داخل الـ Sub-collection
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toMap());

      // 2. تحديث بيانات الغرفة الخارجية
      await _firestore.collection('chats').doc(chatRoomId).set({
        'users': [message.senderId, message.receiverId],

        // 🔥 الحل هنا: حفظ بيانات كلا الطرفين باستخدام الـ ID كمفتاح
        'usersData': {
          message.senderId: {
            'name': message.senderName,
            'image': message.senderProfileImageUrl,
          },
          message.receiverId: {
            'name': receiverName,
            'image': receiverImageUrl,
          }
        },

        'lastMessage': _getLastMessageText(message),
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('فشل في إرسال الرسالة: $e');
    }
  }

  String _getLastMessageText(MessageModel msg) {
    if (msg.type == 'image') return '📷 صورة';
    if (msg.type == 'product') return '📦 استفسار عن إعلان';
    return msg.text;
  }

  // رفع الصور
  Future<String> uploadImage(File file) async {
    try {
      // 1. تأكد من وجود جلسة مصادقة (مجهولة) قبل الرفع،
      //    لأن قواعد الأمان تشترط request.auth != null
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      debugPrint(
        '📦 bucket: ${_storage.bucket}, '
        'auth uid: ${FirebaseAuth.instance.currentUser?.uid}',
      );

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('chat_images/$fileName');

      // 2. تعيين نوع المحتوى صراحةً ليتوافق مع شرط contentType في الرولز
      final TaskSnapshot snapshot = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      // إظهار الخطأ الحقيقي من Firebase بدل رسالة عامة
      debugPrint(
        '❌ Storage upload failed → code: ${e.code}, message: ${e.message}, '
        'bucket: ${_storage.bucket}',
      );
      rethrow;
    } catch (e) {
      debugPrint('❌ Storage upload unexpected error: $e');
      rethrow;
    }
  }

  // جلب الرسائل
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // أضف هذه الدالة داخل ChatRepository
  Stream<QuerySnapshot> getMyChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId) // هات المحادثات اللي أنا طرف فيها
        .orderBy('timestamp', descending: true) // الأحدث فوق
        .snapshots();
  }
}