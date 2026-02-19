import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String receiverId;
  final String text;
  final String imageUrl;
  final String type; // 'text', 'image', 'product'
  final Map<String, dynamic>? productData; // بيانات المنتج (اختياري)
  final DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    this.text = '',
    this.imageUrl = '',
    this.type = 'text',
    this.productData,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'type': type,
      'productData': productData, // حفظ بيانات المنتج
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? 'text',
      productData: map['productData'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}