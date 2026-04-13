import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../../../model/admin_user_model.dart';
import 'users_admin_vm.dart';

class UsersAdminScreen extends StatelessWidget {
  const UsersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsersAdminVM(),
      child: Consumer<UsersAdminVM>(
        builder: (context, vm, child) {
          final fontSize = Theme.of(context).textTheme.bodySmall!.fontSize! - 2;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الهيدر والبحث
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(title: 'إدارة المستخدمين', size: fontSize, fontWeight: FontWeight.bold),

                    // مربع البحث
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: TextField(
                        controller: vm.searchController,
                        onChanged: vm.searchUser,
                        style: TextStyle(fontSize: fontSize - 2),
                        decoration: InputDecoration(
                          hintText: 'ابحث بالاسم، الإيميل، أو رقم الجوال...',
                          hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: fontSize - 5,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                // قائمة المستخدمين
                Expanded(
                  child: vm.isLoading
                      ? Center(child: CircularProgressIndicator(color: AppColors.current.primary))
                      : vm.filteredUsers.isEmpty
                      ? Center(child: CustomText(title: 'لا يوجد مستخدمين', size: fontSize - 2))
                      : ListView.builder(
                    itemCount: vm.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = vm.filteredUsers[index];
                      return _buildUserHorizontalCard(context, vm, user, fontSize);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // الكرت الأفقي الخاص بالمستخدم
  Widget _buildUserHorizontalCard(BuildContext context, UsersAdminVM vm, AdminUserModel user, double fontSize) {
    // تحديد لون الأيقونة بناءً على نوع المستخدم
    final isSpecialUser = user.userType == 0 || user.userName == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () => _showUserDetailsDialog(context, vm, user, fontSize),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 1. الصورة أو الأيقونة
              CircleAvatar(
                radius: 25,
                backgroundColor: isSpecialUser ? Colors.orange.withOpacity(0.2) : const Color(0xFFF4F7FE),
                backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                    ? Icon(isSpecialUser ? Icons.admin_panel_settings : Icons.person, color: isSpecialUser ? Colors.orange : Colors.blue)
                    : null,
              ),
              const SizedBox(width: 16),

              // 2. الاسم والبريد الإلكتروني (يأخذ مساحة مرنة)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(title: user.displayName, fontWeight: FontWeight.bold, size: fontSize - 2),
                    const SizedBox(height: 4),
                    CustomText(title: user.email ?? user.phoneNumber ?? 'لا يوجد تواصل', color: Colors.grey, size: fontSize - 4),
                  ],
                ),
              ),

              // 3. المدينة والمنطقة
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        CustomText(title: user.cityName ?? 'غير محدد', size: fontSize - 4),
                      ],
                    ),
                    if (user.regionName != null) ...[
                      const SizedBox(height: 4),
                      CustomText(title: user.regionName!, color: Colors.grey, size: fontSize - 5),
                    ]
                  ],
                ),
              ),

              // 4. تاريخ التسجيل
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(title: 'تاريخ الانضمام', color: Colors.grey, size: fontSize - 5),
                    const SizedBox(height: 4),
                    CustomText(title: vm.formatDate(user.createdAt), fontWeight: FontWeight.bold, size: fontSize - 4),
                  ],
                ),
              ),

              // 5. أيقونة التفاصيل
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // الديالوج التفصيلي للمستخدم
  // =========================================================

  void _showUserDetailsDialog(BuildContext context, UsersAdminVM vm, AdminUserModel user, double fontSize) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الهيدر
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                      color: Color(0xFFF4F7FE),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(title: 'ملف المستخدم', fontWeight: FontWeight.bold, size: fontSize),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),

                // المحتوى
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // قسم الصورة والاسم
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFFF4F7FE),
                            backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                                ? NetworkImage(user.profileImageUrl!)
                                : null,
                            child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 40, color: Colors.blue)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(title: user.displayName, fontWeight: FontWeight.bold, size: fontSize + 2),
                                if (user.fullName != null && user.userName != null)
                                  CustomText(title: '@${user.userName}', color: Colors.grey, size: fontSize - 2),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: user.lockoutEnabled ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomText(
                                    title: user.lockoutEnabled ? 'حساب محظور' : 'حساب نشط',
                                    color: user.lockoutEnabled ? Colors.red : Colors.green,
                                    size: fontSize - 4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // قسم الإحصائيات والأرقام
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard('الإعلانات النشطة', user.numberOfProducts.toString(), Colors.blue, fontSize),
                          _buildStatCard('الإعلانات المنتهية', user.numberOfExpireProducts.toString(), Colors.orange, fontSize),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // قسم تفاصيل الاتصال
                      _buildDetailRow(Icons.email_outlined, 'البريد الإلكتروني', user.email ?? 'غير متوفر', fontSize - 2),
                      _buildDetailRow(Icons.phone_outlined, 'رقم الجوال', user.phoneNumber ?? 'غير متوفر', fontSize- 2),
                      _buildDetailRow(Icons.location_city_outlined, 'المدينة / المنطقة', '${user.cityName ?? 'غير محدد'} - ${user.regionName ?? 'غير محدد'}', fontSize- 2),
                      _buildDetailRow(Icons.calendar_today_outlined, 'تاريخ الانضمام', vm.formatDate(user.createdAt), fontSize- 2),

                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFAFBFF), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(title: 'النبذة التعريفية (Bio):', color: Colors.grey, size: fontSize - 4),
                              const SizedBox(height: 4),
                              CustomText(title: user.bio!, size: fontSize - 2),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ودجت مساعدة لعرض الإحصائيات (مربعات الأرقام)
  Widget _buildStatCard(String title, String value, Color color, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CustomText(title: value, color: color, fontWeight: FontWeight.bold, size: fontSize + 4),
          const SizedBox(height: 4),
          CustomText(title: title, color: Colors.black87, size: fontSize - 4),
        ],
      ),
    );
  }

  // ودجت مساعدة لصفوف التفاصيل
  Widget _buildDetailRow(IconData icon, String title, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: CustomText(title: title, color: Colors.grey, size: fontSize - 2),
          ),
          Expanded(
            child: CustomText(title: value, fontWeight: FontWeight.bold, size: fontSize - 2),
          ),
        ],
      ),
    );
  }
}