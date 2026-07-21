import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../configurations/localization/i18n.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../../configurations/user_preferences.dart';
import '../../../custom_widgets/custom_button.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../../custom_widgets/custom_text_field.dart';
import '../../../custom_widgets/dialog/overlay_helper.dart';
import '../../common/common_view_model.dart';

class DeleteAccountPage extends StatefulWidget {
  final VoidCallback? onDeleted;
  final bool showSubscriptionsLink;
  final bool requireReauth;

  const DeleteAccountPage({
    super.key,
    this.onDeleted,
    this.showSubscriptionsLink = false,
    this.requireReauth = false,
  });

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _confirmController = TextEditingController(); // يكتب "حذف"
  final _passwordController = TextEditingController(); // إعادة تحقق (اختياري)

  bool _ack = false;
  bool _isBusy = false;

  @override
  void dispose() {
    _confirmController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openSubscriptions() async {
    // رابط آبل لإدارة الاشتراكات
    final candidates = <String>[
      'itms-apps://apps.apple.com/account/subscriptions',
      'https://apps.apple.com/account/subscriptions',
    ];
    for (final link in candidates) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح صفحة إدارة الاشتراكات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _ack &&
        _confirmController.text.trim() == 'حذف' &&
        (!_isBusy) &&
        (!widget.requireReauth || _passwordController.text.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('حذف الحساب')),
      body: AbsorbPointer(
        absorbing: _isBusy,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                const Icon(Icons.delete_forever, size: 64),
                const SizedBox(height: 12),
                const CustomText(title:
                'سيتم حذف حسابك وبيانات تسجيل الدخول والتفضيلات ورموز الإشعارات. '
                    'ستظل سجلاتك الأكاديمية (مثل الدرجات والملاحظات وطلب القبول) محفوظة لدى المدرسة '
                    'باعتبارها سجلات مؤسسية نلتزم قانونيًا بالاحتفاظ بها.',

                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                CustomText(title:
                'Your account (credentials, preferences, push tokens) will be deleted. '
                    'Academic records (grades, teacher notes, admission) are retained by the school as institutional records.',
                  color: Colors.grey,
                  size: Theme
                      .of(context)
                      .textTheme
                      .bodySmall!
                      .fontSize,
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                            title: 'سيتم حذفه:', fontWeight: FontWeight.bold),
                        SizedBox(height: 6),
                        CustomText(
                          title: '• بيانات تسجيل الدخول (البريد/الجوال)',
                          size: Theme
                              .of(context)
                              .textTheme
                              .bodySmall!
                              .fontSize,),
                        CustomText(
                          title: '• التفضيلات والإعدادات المحلية', size: Theme
                            .of(context)
                            .textTheme
                            .bodySmall!
                            .fontSize,),
                        // CustomText(title: '• رموز الإشعارات (لإيقاف الإشعارات من التطبيق)' , size: Theme.of(context).textTheme.bodySmall!.fontSize,),
                        SizedBox(height: 12),
                        CustomText(title: 'سيبقى محفوظًا:',
                            fontWeight: FontWeight.bold),
                        SizedBox(height: 6),
                        CustomText(
                          title: '• السجلات الأكاديمية (الدرجات/الملاحظات/طلب القبول) بحكم سياسة المدرسة',
                          size: Theme
                              .of(context)
                              .textTheme
                              .bodySmall!
                              .fontSize,),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _ack,
                        onChanged: (v) => setState(() => _ack = v ?? false),
                        title: CustomText(
                          title: 'أفهم أن سجلاتي الأكاديمية ستظل محفوظة لدى المدرسة.',
                          size: Theme
                              .of(context)
                              .textTheme
                              .bodySmall!
                              .fontSize,),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (widget.requireReauth) ...[
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'تأكيد كلمة المرور (إن لزم)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (widget.requireReauth &&
                                (v == null || v.isEmpty)) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmController,
                        decoration: const InputDecoration(
                          labelText: 'اكتب كلمة "حذف" للتأكيد',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if ((v ?? '').trim() != 'حذف') {
                            return 'للمتابعة، اكتب كلمة "حذف" تمامًا';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isBusy ? null : () =>
                                  Navigator.of(context).maybePop(),
                              child: const Text('رجوع'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: canSubmit ? _deleteAccount : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('حذف الحساب'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // const Text(
                //   'معلومة مهمة: يمكنك طلب نسخة من بياناتك قبل حذف الحساب إن كانت المدرسة تتيح ذلك.',
                //   style: TextStyle(fontSize: 12, color: Colors.grey),
                // ),
                const SizedBox(height: 12),
              ],
            ),

            if (_isBusy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x88000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (_isBusy) return;
    if (!_formKey.currentState!.validate()) return;

    CommonViewModel vm = Provider.of<CommonViewModel>(
        context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('تأكيد حذف الحساب'),
            content: const Text(
              'سيتم حذف حسابك وبيانات تسجيل الدخول والتفضيلات ورموز الإشعارات. '
                  'ستظل سجلاتك الأكاديمية (الدرجات/الملاحظات/طلب القبول) محفوظة لدى المدرسة '
                  'كسجلات مؤسسية لا تُحذف ضمن هذه العملية.',
              textAlign: TextAlign.start,
            ),
            actions: [

              CustomButton(onTap: () async {

                bool isOk = false;
                //
                // await vm.deleteAccount(
                //   context: context,
                //   password: UserPreferences().getString(
                //       key: AppStrings.pass, defaultValue: ''),
                //   deleteAcc: 'admin123',
                // );

                if (isOk) {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // لمنع إغلاق الديالوج عند الضغط خارجه
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(S.of(context)!.processDone),
                        content: const Text("تم حذف حسابك بنجاح"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // تنفيذ الخروج والتوجه لصفحة تسجيل الدخول
                              UserPreferences().logout(context);
                            },
                            child: const Text("حسناً"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // لمنع إغلاق الديالوج عند الضغط خارجه
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(S.of(context)!.processDone),
                        content: const Text("لم يتم حذف حسابك بنجاح"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // تنفيذ الخروج والتوجه لصفحة تسجيل الدخول
                              UserPreferences().logout(context);
                            },
                            child: const Text("حسناً"),
                          ),
                        ],
                      );
                    },
                  );
                }
              }, text: 'تأكيد الحذف',
                loading: vm.isLoading,
                btnColor: Colors.red,
                borderColor: Colors.red,
              ),

              SizedBox(
                height: 10,
              ),

              CustomButton(
                onTap: () => Navigator.pop(context, false),
                text: 'إلغاء',
                btnColor: Colors.grey,
                borderColor: Colors.grey,
              ),

            ],
          ),
    );

    if (confirm != true) return;
  }

// void deleteAccount(BuildContext ctx) async {
//    CommonViewModel vm = Provider.of<CommonViewModel>(ctx, listen: false);
//
//    bool isOk = await vm.deleteAccount(
//      context: ctx,
//      password: UserPreferences().getString(key: AppStrings.pass, defaultValue: ''),
//      deleteAcc: 'admin123',
//    );
//
//    if(isOk){
//      OverlayHelper.showSuccessDialog(
//          context, S.of(context)!.processDone,
//          description: "تم حذف حسابك بك بنجاح",
//          confirmButtonTitle: "حسنا",
//          onConfirmButtonTap: (){
//            UserPreferences().logout(context);
//          }
//      );
//
//    }else{
//      OverlayHelper.showSuccessDialog(
//          context, S.of(context)!.processDone,
//          description: "حدث خطأ في حذف حسابك",
//          confirmButtonTitle: "حسنا",
//          onConfirmButtonTap: (){
//            Navigator.pop(context);
//          }
//      );
//    }
//  }

}