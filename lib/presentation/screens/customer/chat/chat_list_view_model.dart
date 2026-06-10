import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 استيراد مكتبة المصادقة
import 'package:flutter/material.dart';

import 'chat_repo.dart';

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();
  final String currentUserId;

  // 👈 تحويل الستريم إلى متغير يمكن تهيئته لاحقاً
  Stream<QuerySnapshot>? chatsStream;

  ChatListViewModel({required this.currentUserId}) {
    _initFirebaseAndStream();
  }

  // 👈 هذه الدالة تتأكد من تسجيل الدخول قبل جلب المحادثات
  Future<void> _initFirebaseAndStream() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint("✅ تم تسجيل الدخول المجهول بنجاح لصفحة القائمة");
      }

      // بمجرد نجاح الدخول، نقوم بفتح الستريم
      chatsStream = _repo.getMyChats(currentUserId);
      notifyListeners(); // نحدث الواجهة لإظهار البيانات
    } catch (e) {
      debugPrint("❌ خطأ في المصادقة: $e");
    }
  }

  String getOtherUserId(List<dynamic> users) {
    return users.firstWhere((id) => id != currentUserId, orElse: () => '');
  }
}