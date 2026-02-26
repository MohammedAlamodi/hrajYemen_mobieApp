import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/user_preferences.dart';
import 'package:ye_hraj/model/product_model.dart';
import '../../../model/message_model.dart';
import '../../../model/seller_model.dart';
import '../../custom_widgets/custom_text.dart';
import 'chat_view_model.dart';

class ChatScreen extends StatelessWidget {
  final String currentUserId;
  final String senderProfileImageUrl;
  final String senderName;
  final String otherUserId;
  final String otherUserName;
  final ProductModel? productContext;
  final String otherUserImageUrl;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.senderName,
    required this.senderProfileImageUrl,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImageUrl, // أضف هذا
    this.productContext,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(
        currentUserId: currentUserId,
        senderName: senderName,
        otherUserName: otherUserName,
        otherUserImageUrl: otherUserImageUrl,
        senderProfileImageUrl: senderProfileImageUrl,
        otherUserId: otherUserId,
        productContext: productContext, // تمرير المنتج للـ VM
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        appBar: AppBar(
          title: CustomText(
            title: otherUserName,
            size: 16,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: otherUserId == '0'
            ? Center(
                child: CustomText(
                  title: ' حدث خطأ',
                  color: Colors.grey,
                ),
              )
            : Consumer<ChatViewModel>(
                builder: (context, vm, child) {
                  return Column(
                    children: [
                      // 1. قائمة الرسائل
                      Expanded(
                        child: StreamBuilder(
                          stream: vm.messagesStream,
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data.docs.isEmpty) {
                              return const Center(
                                child: CustomText(
                                  title: 'ابدأ المحادثة الآن',
                                  color: Colors.grey,
                                ),
                              );
                            }

                            return ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel msg = MessageModel.fromMap(
                                  snapshot.data.docs[index].data()
                                      as Map<String, dynamic>,
                                );
                                return _MessageBubble(
                                  message: msg,
                                  isMe: msg.senderId == vm.currentUserId,
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // 2. منطقة الإدخال + كارد المنتج المعلق
                      _InputArea(vm: vm),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ✅ منطقة الإدخال (مع كارد المنتج المعلق)
// -----------------------------------------------------------------------------
class _InputArea extends StatelessWidget {
  final ChatViewModel vm;

  const _InputArea({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E8EF))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔥 الكارد المعلق (يظهر فقط إذا جاء من صفحة منتج ولم يرسل بعد)
          if (vm.showProductPreview && vm.attachedProductData != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2462EB).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  // صورة المنتج
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      vm.attachedProductData!['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey, width: 50),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // التفاصيل
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          title:
                              'استفسار بخصوص: ${vm.attachedProductData!['title']}',
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2462EB),
                        ),
                        CustomText(
                          title: '${vm.attachedProductData!['price']}',
                          size: 12,
                          color: const Color(0xFF0F162A),
                        ),
                      ],
                    ),
                  ),
                  // زر إغلاق (إلغاء الإرفاق)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: vm.closeProductPreview,
                  ),
                ],
              ),
            ),

          // حقل النص والأزرار
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF63748A),
                  ),
                  onPressed: vm.sendImage,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: vm.msgController,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: const Color(0xFF63748A),
                          fontSize: Theme.of(context).textTheme.bodySmall!.fontSize! - 4

                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFF2462EB),
                  ),
                  onPressed: () => vm.sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ✅ فقاعة الرسالة (تتعامل مع النص، الصور، والمنتجات)
// -----------------------------------------------------------------------------
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2462EB) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
            bottomRight: isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
          ),
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. إذا كانت الرسالة عبارة عن "منتج" (كارت)
              if (message.type == 'product' && message.productData != null)
                _buildProductCardInChat(message.productData!, isMe),

              // 2. إذا كانت صورة
              if (message.type == 'image')
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(message.imageUrl, fit: BoxFit.cover),
                ),

              // 3. النص (يظهر تحت المنتج أو الصورة إذا وجد)
              if (message.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    top: (message.type != 'text') ? 8.0 : 0,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF0F162A),
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),

              const SizedBox(height: 4),
              // الوقت
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تصميم كارت المنتج داخل الشات
  Widget _buildProductCardInChat(Map<String, dynamic> product, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.2) : const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(8),
        border: isMe ? null : Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              product['image'] ?? '',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey, width: 40),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${product['price']} ر.ي',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : const Color(0xFF2462EB),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}
