import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // مهم جداً لميزة النسخ (Clipboard)
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';
import '../../../../custom_widgets/custom_avatar_widget.dart';
import '../../../../custom_widgets/custom_text.dart';
import 'banks_mobile_vm.dart';
import 'payment_methods_view_model.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدمنا MultiProvider لتشغيل الاثنين معاً
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PaymentMethodsViewModel()),
        ChangeNotifierProvider(create: (_) => BanksMobileVM()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.current.appBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const CustomText(
            title: 'طرق دفع العمولة',
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          centerTitle: true,
        ),
        body: Consumer<PaymentMethodsViewModel>(
          builder: (context, paymentVm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. حاسبة العمولة ---
                  _buildSectionTitle('احسب عمولة إعلانك (1%)'),
                  CustomTextField(
                    controller: paymentVm.salePriceController,
                    type: TextInputType.number,
                    onChange: paymentVm.calculateCommission,
                    hint: 'أدخل قيمة بيع السلعة (مثال: 50,000)',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),

                  if (paymentVm.calculatedCommission > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                      child: CustomText(
                        title:
                        'العمولة المستحقة: ${paymentVm.calculatedCommission.toStringAsFixed(1)} ريال',
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        size: 14,
                      ),
                    ),
                  const SizedBox(height: 32),

                  // --- 2. الحسابات البنكية ---
                  _buildSectionTitle('الحسابات المعتمدة للدفع'),
                  const SizedBox(height: 10),

                  Consumer<BanksMobileVM>(
                    builder: (context, banksVm, _) {
                      return Column(
                        children: [
                          // اللودينج الصغير في الأعلى عند المزامنة مع السيرفر
                          if (banksVm.isServerLoading) ...[
                            const LinearProgressIndicator(
                              minHeight: 3,
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(height: 10),
                          ],

                          // عرض الحسابات من السيرفر أو اللوكال
                          banksVm.accounts.isEmpty && !banksVm.isServerLoading
                              ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'لا توجد حسابات بنكية مضافة حالياً',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                              : ListView.separated(
                            // هذه الخصائص ضرورية لتجنب تعارض الـ Scroll مع SingleChildScrollView
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: banksVm.accounts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final bank = banksVm.accounts[index];

                              // استخدام تصميمك المميز لعرض البيانات
                              return _buildBankAccountCard(
                                context: context,
                                bankName: bank.name,
                                accountNumber: bank.accountNumber,
                                imageUrl: bank.imageUrl,
                                iconPath: Icons.account_balance,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // --- 3. تعليمات ما بعد الدفع ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2462EB).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF2462EB),
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        const CustomText(
                          title: 'ماذا أفعل بعد التحويل؟',
                          fontWeight: FontWeight.bold,
                          size: 16,
                          color: Color(0xFF0F162A),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'بعد إتمام عملية التحويل، يرجى إرسال صورة السند (الوصل) مع رقم الإعلان إلى رقم خدمة العملاء عبر الواتساب لتأكيد الدفع.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            color: Color(0xFF63748A),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // هنا تضع كود فتح الواتساب باستخدام مكتبة url_launcher
                            // مثال: launchUrl(Uri.parse("https://wa.me/967777000000"));
                          },
                          icon: const Icon(Icons.wechat, color: Colors.white),
                          label: const Text(
                            'إرسال السند عبر الواتساب',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- دوال مساعدة ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: CustomText(
        title: title,
        size: 16,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F162A),
      ),
    );
  }

  Widget _buildBankAccountCard({
    required BuildContext context,
    required String bankName,
    required String accountNumber,
    required String? imageUrl,
    required IconData iconPath,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? CustomAvatarWidget(imageUrl: imageUrl, size: 28, iconSize: 23)
                : Icon(iconPath, color: const Color(0xFF63748A), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title: bankName,
                  fontWeight: FontWeight.bold,
                  size: 15,
                ),
                const SizedBox(height: 4),
                // CustomText(title: accountName, color: Colors.grey, size: 12),
                // const SizedBox(height: 4),
                CustomText(
                  title: accountNumber,
                  color: const Color(0xFF2462EB),
                  fontWeight: FontWeight.bold,
                  size: 16,
                ),
              ],
            ),
          ),
          // زر النسخ السحري
          InkWell(
            onTap: () {
              // نسخ الرقم للحافظة
              Clipboard.setData(ClipboardData(text: accountNumber)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم نسخ رقم الحساب: $accountNumber',
                      style: const TextStyle(fontFamily: 'Tajawal'),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const CustomText(
                title: 'نسخ',
                color: Color(0xFF2462EB),
                fontWeight: FontWeight.bold,
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}