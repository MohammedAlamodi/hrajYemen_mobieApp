import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // مهم جداً لميزة النسخ (Clipboard)
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';
import '../../../../custom_widgets/custom_avatar_widget.dart';
import '../../../../custom_widgets/custom_text.dart';
import 'payment_methods_view_model.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentMethodsViewModel(),
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
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. حاسبة العمولة ---
                  _buildSectionTitle('احسب عمولة إعلانك (1%)'),
                  CustomTextField(
                    controller: vm.salePriceController,
                    type: TextInputType.number,
                    onChange: vm.calculateCommission,
                    hint: 'أدخل قيمة بيع السلعة (مثال: 50,000)',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),

                  if (vm.calculatedCommission > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                      child: CustomText(
                        title:
                            'العمولة المستحقة: ${vm.calculatedCommission.toStringAsFixed(1)} ريال',
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        size: 14,
                      ),
                    ),
                  const SizedBox(height: 32),

                  // --- 2. الحسابات البنكية ---
                  _buildSectionTitle('الحسابات المعتمدة للدفع'),
                  SizedBox(height: 10),

                  _buildBankAccountCard(
                    context: context,
                    bankName: 'بنك بن دول',
                    accountName: 'حراج اليمن للإعلانات',
                    accountNumber: '00012345678',
                    imageUrl:
                        'https://bindowalgroup.com/static/uploads/companies_logo/IMG_Bin_Dowal_Group_v0bYqKg1YBCDGDLdZvN0eiIPXFPElyWpSL3tp11c.png',
                    iconPath: Icons.account_balance_wallet,
                  ),

                  const SizedBox(height: 12),

                  _buildBankAccountCard(
                    context: context,
                    bankName: ' صرافة العمقي',
                    accountName: 'حراج اليمن للإعلانات',
                    imageUrl:
                        'https://scontent.fkul10-2.fna.fbcdn.net/v/t39.30808-6/494039041_1070032821821822_4217568367567705321_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=1d70fc&_nc_ohc=sgn9xgpGgHwQ7kNvwEutpSR&_nc_oc=Adk3ICW7Qr1jZKeIfMV2aE96tV7Qmno6ZYLZRhf7a8KNh0w5j1h5Llgm6xI9kSQjL1KpcPIUTCrS5-Qi3p8GjNzD&_nc_zt=23&_nc_ht=scontent.fkul10-2.fna&_nc_gid=Ej5nkMvEeqX0TiirlZHD3A&_nc_ss=8&oh=00_Afv8fMZj0AHSnKTiMSaT0e56AiyHV8PXHQVz7rt7-RSEqA&oe=69AA5981',
                    accountNumber: '777000000',
                    iconPath: Icons.phone_android,
                  ),
                  const SizedBox(height: 12),

                  _buildBankAccountCard(
                    context: context,
                    bankName: 'بنك الكريمي',
                    accountName: 'حراج اليمن للإعلانات',
                    accountNumber: '123456789',
                    imageUrl:
                        'https://scontent.fkul10-2.fna.fbcdn.net/v/t39.30808-6/515509762_24046243518325951_629679767048178728_n.jpg?stp=dst-jpg_s1080x2048_tt6&_nc_cat=111&ccb=1-7&_nc_sid=7b2446&_nc_ohc=34C1tYpuaZ0Q7kNvwGuAxEG&_nc_oc=AdlRqwFImE4Oli_a-CQFTFXm-ASWTwmOvT6ElyfELo-pOSCMbCPGwbczU5iYgvBLRrBeD4T93-9c8l7x2-3RxqkR&_nc_zt=23&_nc_ht=scontent.fkul10-2.fna&_nc_gid=rKY0dNWeTjCUTR4C57n52A&_nc_ss=8&oh=00_AfuOb7Q-ScmZ4Ut_2dFfGQx5r3bT7fJNI-Kc1ob3TPk95A&oe=69AA6D66',
                    iconPath: Icons.account_balance,
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
                          // يفضل استخدام أيقونة واتساب إذا توفرت
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
                            // لون الواتساب الرسمي
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
    required String accountName,
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
            child: imageUrl != null
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
                CustomText(title: accountName, color: Colors.grey, size: 12),
                const SizedBox(height: 4),
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
