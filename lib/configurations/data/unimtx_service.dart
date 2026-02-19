import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class UnimtxService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.unimtx.com', // استبدل بعنوان API المناسب
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<void> sendOtp({
    required String phoneNumber,
    required String message,
    required String apiKey,
  }) async {
    try {
      final response = await _dio.post(
        '/otp/send',
        data: {
          'phone_number': phoneNumber,
          'message': message,
          'api_key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        // نجاح إرسال OTP
        print('OTP sent successfully');
      } else {
        throw Exception('Failed to send OTP: ${response.data}');
      }
    } on DioException catch (e) {
      // خطأ في الاتصال بـ API
      print('Error sending OTP: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required String apiKey,
  }) async {
    try {
      final response = await _dio.post(
        '/otp/verify',
        data: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
          'api_key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return response.data['status'] == 'success';
      } else {
        throw Exception('Failed to verify OTP: ${response.data}');
      }
    } on DioException catch (e) {
      print('Error verifying OTP: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }
}



class UnimatrixService {
  final String baseUrl = 'https://api.unimtx.com'; // رابط الـ API
  final String apiKey = 'MXpVjBcgAsrCeweZHsQ4s9'; // ضع مفتاح الـ API هنا

  Future<void> sendSMS(String phoneNumber, String message) async {
    final url = Uri.parse('$baseUrl/otp/send');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'to': "+967738883773",
        'message': 'Hi Mohammed',
      }),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully: ${response.body}');
    } else {
      print('Failed to send message: ${response.body}');
    }
  }
}
