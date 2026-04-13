import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat_repo.dart';

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();
  final String currentUserId;

  ChatListViewModel({required this.currentUserId});

  // الستريم الخاص بالقائمة
  Stream<QuerySnapshot> get chatsStream => _repo.getMyChats(currentUserId);

  // دالة مساعدة لمعرفة آيدي الطرف الآخر من المصفوفة
  String getOtherUserId(List<dynamic> users) {
    return users.firstWhere((id) => id != currentUserId, orElse: () => '');
  }
}