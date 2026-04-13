import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';

import '../../../../custom_widgets/custom_text.dart';

class TermsAndPoliciesScreen extends StatelessWidget {
  static const String routeName = '/TermsAndPoliciesScreen';

  const TermsAndPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.current.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const CustomText(
          title: 'الشروط والسياسات',
          fontWeight: FontWeight.bold,
          size: 18,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E8EF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('مقدمة'),
              _buildSectionText(context,
                'مرحباً بك في تطبيقنا. باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بالشروط والأحكام الموضحة أدناه. يرجى قراءتها بعناية قبل استخدام خدماتنا في البيع والشراء والمراسلة.',
              ),
              const Divider(height: 30, color: Color(0xFFE1E8EF)),

              _buildSectionTitle('1. الحسابات والتسجيل'),
              _buildSectionText(context,
                '• يجب أن تكون المعلومات المقدمة أثناء التسجيل (مثل الاسم، رقم الهاتف، والبريد الإلكتروني) صحيحة ودقيقة.\n'
                    '• أنت مسؤول مسؤولية كاملة عن الحفاظ على سرية معلومات حسابك وكلمة المرور.\n'
                    '• يمنع إنشاء حسابات وهمية أو استخدام التطبيق لأغراض احتيالية.',
              ),
              const Divider(height: 30, color: Color(0xFFE1E8EF)),

              _buildSectionTitle('2. نشر الإعلانات والمحتوى'),
              _buildSectionText(context,
                '• يلتزم البائع بتقديم وصف دقيق وصور حقيقية للمنتجات أو السيارات أو العقارات المعروضة.\n'
                    '• يُمنع منعاً باتاً نشر إعلانات لسلع ممنوعة قانونياً، أو مسروقة، أو تنتهك حقوق الملكية الفكرية.\n'
                    '• يحق لإدارة التطبيق حذف أي إعلان يخالف السياسات دون الرجوع للمعلن.',
              ),
              const Divider(height: 30, color: Color(0xFFE1E8EF)),

              _buildSectionTitle('3. نظام المحادثات والتواصل'),
              _buildSectionText(context,
                '• خُصص نظام المحادثات (الشات) لتسهيل التواصل بين البائع والمشتري لإتمام الصفقات فقط.\n'
                    '• يُمنع استخدام المحادثات لإرسال رسائل مزعجة (Spam)، أو روابط مشبوهة، أو ألفاظ مسيئة.\n'
                    '• نحتفظ بالحق في حظر أي مستخدم يسيء استخدام نظام المراسلة.',
              ),
              const Divider(height: 30, color: Color(0xFFE1E8EF)),

              _buildSectionTitle('4. عمولة التطبيق (معاهدة الاستخدام)'),
              _buildSectionText(context,
                '• يعتبر هذا التطبيق وسيطاً إعلانياً. في حال إتمام البيع عن طريق التطبيق، تعتبر العمولة المحددة في النظام أمانة في ذمة البائع.\n'
                    '• يلتزم البائع بتحويل عمولة التطبيق عبر وسائل الدفع المتاحة في صفحة "دفع العمولة" فور إتمام الصفقة.\n'
                    '• عدم دفع العمولة يعرض الحساب للإيقاف الدائم وتُعتبر ديناً في ذمة البائع.',
              ),
              const Divider(height: 30, color: Color(0xFFE1E8EF)),

              _buildSectionTitle('5. سياسة الخصوصية'),
              _buildSectionText(context,
                '• نحن نحترم خصوصيتك. لن نقوم بمشاركة بياناتك الشخصية (مثل رقم الهاتف أو البريد الإلكتروني) مع جهات خارجية لأغراض تسويقية دون موافقتك.\n'
                    '• قد نستخدم بعض البيانات لتحسين تجربة الاستخدام، وإصلاح الأعطال، ومراقبة الجودة.',
              ),
              const Divider(height: 30, color: Color(0xFFE1E8EF)),

              _buildSectionTitle('6. التعديلات على الشروط'),
              _buildSectionText(context,
                'يحق لإدارة التطبيق تعديل هذه الشروط والسياسات في أي وقت. استمرارك في استخدام التطبيق بعد أي تعديل يُعد موافقة ضمنية على الشروط الجديدة.',
              ),

              const SizedBox(height: 20),
              Center(
                child: CustomText(
                  title: 'آخر تحديث: مارس 2026',
                  color: Colors.grey,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لتصميم العناوين
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CustomText(
        title: title,
        size: 16,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF2462EB), // اللون الأزرق الخاص بالتطبيق
      ),
    );
  }

  // دالة مساعدة لتصميم النصوص التفصيلية
  Widget _buildSectionText(BuildContext context, String text) {
    return CustomText(
      title: text,
      size: Theme.of(context).textTheme.bodySmall!.fontSize,
      color: Color(0xFF0F162A),
      textHeight: 1.6, // تباعد الأسطر لراحة العين في القراءة
      textAlign: TextAlign.justify,
    );
  }
}