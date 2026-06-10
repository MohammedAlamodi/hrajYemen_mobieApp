import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_button.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';

import '../../../../model/bank_account_model.dart';
import 'banks_admin_view_model.dart';
// استيراد الـ VM والمودل

class BanksAdminScreen extends StatelessWidget {
  const BanksAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    BanksAdminVM vm = Provider.of<BanksAdminVM>(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                title: '',
                size: Theme.of(context).textTheme.bodySmall!.fontSize!,
                fontWeight: FontWeight.bold,
              ),
              CustomButton(
                onTap: () => _showBankDialog(context, vm),
                iconData: const Icon(Icons.add),
                text: 'إضافة حساب جديد',
                btnTextSize:
                    Theme.of(context).textTheme.bodySmall!.fontSize! - 4,
              ),
            ],
          ),
          const Divider(height: 30),

          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.accounts.isEmpty
                ? Center(
                    child: CustomText(
                      title: 'لا توجد حسابات',
                      size: Theme.of(context).textTheme.bodySmall!.fontSize!,
                    ),
                  )
                : ListView.builder(
                    itemCount: vm.accounts.length,
                    itemBuilder: (context, index) {
                      final bank = vm.accounts[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 15),
                        borderOnForeground: true,
                        shadowColor: AppColors.current.primary50,
                        elevation: 5,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.current.primary,
                            backgroundImage:
                                (bank.imageUrl != null &&
                                    bank.imageUrl!.isNotEmpty)
                                ? NetworkImage(bank.imageUrl!)
                                : null,
                            child:
                                (bank.imageUrl == null ||
                                    bank.imageUrl!.isEmpty)
                                ? Icon(
                                    Icons.food_bank_outlined,
                                    color: AppColors.current.primary,
                                  )
                                : null,
                          ),

                          title: CustomText(
                            title: bank.name,
                            fontWeight: FontWeight.bold,
                            size: Theme.of(
                              context,
                            ).textTheme.bodySmall!.fontSize!,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(
                              title: bank.accountNumber,
                              size: Theme.of(
                                context,
                              ).textTheme.bodySmall!.fontSize!,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () =>
                                    _showBankDialog(context, vm, bank: bank),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDeleteCategory(context , vm ,bank.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(
    BuildContext context,
    BanksAdminVM vm,
    int bankId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        final fontSize = Theme.of(context).textTheme.bodySmall!.fontSize!;
        return AlertDialog(
          backgroundColor: Colors.white,
          title: CustomText(
            title: 'تأكيد الحذف',
            color: Colors.red,
            size: fontSize + 2,
            fontWeight: FontWeight.bold,
          ),
          content: CustomText(
            title: 'سيتم حذف الحساب البنكي نهائياً من السيرفر. هل أنت متأكد؟',
            size: fontSize - 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: CustomText(
                title: 'إلغاء',
                color: Colors.grey,
                size: fontSize - 2,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await vm.deleteAccount(bankId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: CustomText(
                title: 'نعم، احذف',
                color: Colors.white,
                size: fontSize - 2,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBankDialog(
    BuildContext context,
    BanksAdminVM vm, {
    BankAccountModel? bank,
  }) {
    final nameController = TextEditingController(text: bank?.name ?? '');
    final accountController = TextEditingController(
      text: bank?.accountNumber ?? '',
    );
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          // مهم جداً لتحديث حالة الصورة داخل الديلوج
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: CustomText(
                title: bank == null ? 'إضافة حساب جديد' : 'تعديل الحساب',
                size: Theme.of(context).textTheme.bodySmall!.fontSize!,
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: nameController,
                      labelText: 'اسم البنك',
                      // decoration: const InputDecoration(
                      //   labelText: 'اسم الحساب (مثال: حساب العمقي)',
                      //   border: OutlineInputBorder(),
                      // ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: accountController,
                      hint: 'مثال: 1234567890',
                    ),
                    const SizedBox(height: 20),

                    // معاينة الصورة أو زر الاختيار
                    InkWell(
                      onTap: () async {
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = pickedFile;
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: selectedImage != null
                            ? Center(
                                child: CustomText(
                                  title: 'تم إرفاق: ${selectedImage!.name}',
                                  color: Colors.green,
                                  size:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodySmall!.fontSize! -
                                      3,
                                ),
                              )
                            : (bank?.imageUrl != null &&
                                  bank!.imageUrl!.isNotEmpty)
                            ? Image.network(
                                bank.imageUrl!,
                              ) // عرض الصورة القديمة إذا كان تعديل
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  CustomText(
                                    title: 'اضغط لاختيار شعار البنك',
                                    size:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall!.fontSize! -
                                        4,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: vm.isActionLoading
                      ? null
                      : () => Navigator.pop(ctx),
                  child: CustomText(
                    title: 'إلغاء',
                    color: Colors.red,
                    size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5,
                  ),
                ),
                ElevatedButton(
                  onPressed: vm.isActionLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty ||
                              accountController.text.isEmpty)
                            return;

                          final success = await vm.saveAccount(
                            context,
                            bank: bank,
                            name: nameController.text,
                            accountNumber: accountController.text,
                            image: selectedImage,
                          );

                          if (success && ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                        },
                  child: vm.isActionLoading
                      ? SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: AppColors.current.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : CustomText(
                          title: 'حفظ البيانات',
                          size:
                              Theme.of(context).textTheme.bodySmall!.fontSize! -
                              5,
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
