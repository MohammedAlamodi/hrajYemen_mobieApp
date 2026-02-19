import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../configurations/data/unimtx_service.dart';

class OtpPage extends StatefulWidget {
  static const String routeName = "/OtpPage";

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final UnimtxService _unimtxService = UnimtxService();
  final UnimatrixService _unimatrixService = UnimatrixService();

  String _apiKey = 'MXpVjBcgAsrCeweZHsQ4s9'; // ضع مفتاح API الخاص بك هنا
  bool isResendEnabled = true; // هل يمكن إعادة الإرسال؟
  int remainingSeconds = 0; // العد التنازلي لإعادة الإرسال
  Timer? _timer; // المؤقت

  void _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isNotEmpty) {
      await _unimtxService.sendOtp(
        phoneNumber: phoneNumber,
        message: 'Your OTP code for Sooq Tasheel is: {code}', // رسالة OTP من Unimtx
        apiKey: _apiKey,
      );
      await _unimatrixService.sendSMS('phoneNumber', 'message');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully')),
      );

      // تعطيل إعادة الإرسال وتفعيل المؤقت
      _startResendCountdown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
    }
  }

  void _verifyOtp() async {
    final phoneNumber = _phoneController.text.trim();
    final otpCode = _otpController.text.trim();

    if (phoneNumber.isNotEmpty && otpCode.isNotEmpty) {
      final isVerified = await _unimtxService.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        apiKey: _apiKey,
      );

      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  void _startResendCountdown() {
    setState(() {
      isResendEnabled = false; // تعطيل زر إعادة الإرسال
      remainingSeconds = 30; // 30 ثانية
    });

    _timer?.cancel(); // إلغاء أي مؤقت سابق
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        setState(() {
          isResendEnabled = true; // تمكين زر إعادة الإرسال
        });
        timer.cancel(); // إنهاء المؤقت
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // التأكد من إلغاء المؤقت عند إغلاق الصفحة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isResendEnabled ? _sendOtp : null, // تعطيل الزر إذا لم يكن مسموحًا
              child: isResendEnabled
                  ? const Text('Send OTP')
                  : Text('Resend in $remainingSeconds seconds'),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
