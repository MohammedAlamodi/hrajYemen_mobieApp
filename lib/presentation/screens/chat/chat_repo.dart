import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../model/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // توليد ID موحد للغرفة
  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }

  // إرسال الرسالة
  Future<void> sendMessage(String chatRoomId, MessageModel message) async {
    try {
      // إضافة الرسالة
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toMap());

      // تحديث بيانات الغرفة الخارجية (لأجل قائمة المحادثات)
      await _firestore.collection('chats').doc(chatRoomId).set({
        'users': [message.senderId, message.receiverId],
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
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('chat_images/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('فشل في رفع الصورة');
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