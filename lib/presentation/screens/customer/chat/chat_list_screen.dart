import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl; // لتنسيق الوقت
import 'package:ye_hraj/configurations/data/end_points_manager.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/configurations/resources/strings_manager.dart';
import 'package:ye_hraj/configurations/user_preferences.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';
import 'package:ye_hraj/presentation/screens/common/common_view_model.dart';
import '../../../custom_widgets/Custom_header_bar.dart';
import '../../../custom_widgets/custom_text.dart';
import 'chat_list_view_model.dart';
import '../chat/chat_screen.dart'; // صفحة الشات التي بنيناها سابقاً

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ye_hraj/configurations/data/end_points_manager.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';
import 'chat_list_view_model.dart';
import '../chat/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    CommonViewModel commonVM = Provider.of<CommonViewModel>(context, listen: false);
    final String currentUserId = commonVM.currentUserId;
    // 1. تأكد أن هذا المتغير يحمل قيمة صحيحة وليس فارغاً
    // final String currentUserId = EndPointsStrings.userIdConst;

    debugPrint("ChatListScreen: Current User ID is: $currentUserId"); // للتتبع

    return ChangeNotifierProvider(
      create: (_) => ChatListViewModel(currentUserId: currentUserId),
      child: Scaffold(
        backgroundColor: AppColors.current.appBackground,
        body: Consumer<ChatListViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                const CustomHeaderBar(
                  title: 'الرسائل', // عدلت العنوان من المفضلة إلى الرسائل
                  showSearch: false,
                  showBack: false,
                  onSearchChange: null,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: vm.chatsStream,
                    builder: (context, snapshot) {
                      // 🔥 إضافة مهمة: طباعة الخطأ إذا وجد
                      if (snapshot.hasError) {
                        print("Firestore Error: ${snapshot.error}");
                        return Center(
                            child: Text(
                              "حدث خطأ: ${snapshot.error}",
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            )
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CustomLoadingWidget(
                          text: 'جاري تحميل المحادثات...',
                        ));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (c, i) => const Divider(height: 1, indent: 80, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final users = data['users'] as List<dynamic>? ?? [];
                          if (users.isEmpty) return const SizedBox();

                          // الحصول على ID الطرف الآخر
                          final otherUserId = vm.getOtherUserId(users);

                          final String myName = commonVM.currentUserName; // افترض أنك عرفت هذا في الـ ViewModel
                          final String myImageUrl = '';

                          final lastMessage = data['lastMessage'] ?? '';
                          final Timestamp? timestamp = data['timestamp'];

                          // 🔥 جلب بيانات الطرف الآخر من الـ usersData
                          String displayName = 'مستخدم غير معروف';
                          String displayImage = 'https://placehold.co/100x100';

                          if (data.containsKey('usersData') && data['usersData'][otherUserId] != null) {
                            // إذا كانت المحادثة جديدة وتدعم الهيكلية الجديدة
                            displayName = data['usersData'][otherUserId]['name'] ?? 'مستخدم';
                            displayImage = data['usersData'][otherUserId]['image'] ?? 'https://placehold.co/100x100';
                          } else {
                            // Fallback للمحادثات القديمة في قاعدة البيانات حتى لا ينهار التطبيق
                            displayName = data['senderName'] ?? 'مستخدم';
                            displayImage = data['senderProfileImageUrl'] ?? 'https://placehold.co/100x100';
                          }

                          return _ChatListItem(
                            name: displayName,      // 👈 نعرض اسم الطرف الآخر هنا
                            message: lastMessage,
                            imageUrl: displayImage, // 👈 نعرض صورة الطرف الآخر هنا
                            time: _formatTime(timestamp),
                            unreadCount: 0,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    currentUserId: currentUserId,
                                    // بياناتي أنا (المرسل حالياً)
                                    senderName: myName,
                                    senderProfileImageUrl: myImageUrl,
                                    // بيانات الطرف الآخر
                                    otherUserId: otherUserId,
                                    otherUserName: displayName,
                                    otherUserImageUrl: displayImage,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColors.current.primary.withOpacity(0.1), // تعديل بسيط للون
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline, size: 50, color: AppColors.current.primary),
          ),
          const SizedBox(height: 16),
          const CustomText(title: 'لا توجد محادثات', size: 18, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          const CustomText(title: 'تصفح الإعلانات وتواصل مع البائعين الآن', color: Colors.grey),
        ],
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      return intl.DateFormat.jm().format(date);
    } else if (now.difference(date).inDays == 1) {
      return 'أمس';
    } else {
      return intl.DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

// -----------------------------------------------------------
// ✅ ويدجت عنصر القائمة (تصميم احترافي)
// -----------------------------------------------------------
class _ChatListItem extends StatelessWidget {
  final String name;
  final String message;
  final String imageUrl;
  final String time;
  final int unreadCount;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.name,
    required this.message,
    required this.imageUrl,
    required this.time,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 1. الصورة الشخصية
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F4F6),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {}, // في حالة الخطأ
                    ),
                  ),
                ),
                // نقطة الاتصال (أونلاين) - اختياري
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // 2. الاسم والرسالة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // الاسم
                      Expanded(
                        child: CustomText(
                          title: name,
                          size: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F162A),
                        ),
                      ),
                      // الوقت
                      CustomText(
                        title: time,
                        size: 11,
                        color: unreadCount > 0 ? const Color(0xFF2462EB) : const Color(0xFF9CA2AE),
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      // نص الرسالة الأخيرة
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13.5,
                            color: unreadCount > 0 ? const Color(0xFF0F162A) : const Color(0xFF63748A),
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),

                      // عدد الرسائل غير المقروءة (Badge)
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2462EB),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}