import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../../../model/admin_user_model.dart';
import 'users_admin_vm.dart';
import '../ads_admin/ads_admin_screen.dart';

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
            // ✅ الحل هنا: إعطاء أبعاد صريحة لملء الشاشة بالكامل لتجنب خطأ HitTest
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomText(
                        title: 'إدارة المستخدمين',
                        size: fontSize + 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 2,
                      child: SizedBox(
                        width: 300,
                        height: 40,
                        child: TextField(
                          controller: vm.searchController,
                          onChanged: vm.searchUser,
                          style: TextStyle(fontSize: fontSize - 2),
                          decoration: InputDecoration(
                            hintText: 'ابحث بالاسم، الإيميل، أو رقم الجوال...',
                            hintStyle: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  fontSize: fontSize - 5,
                                  color: Colors.grey,
                                ),
                            prefixIcon: const Icon(Icons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                Expanded(
                  child: vm.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.current.primary,
                          ),
                        )
                      : vm.filteredUsers.isEmpty
                      ? Center(
                          child: CustomText(
                            title: 'لا يوجد مستخدمين',
                            size: fontSize - 2,
                          ),
                        )
                      : ListView.builder(
                          itemCount: vm.filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = vm.filteredUsers[index];
                            return _buildUserHorizontalCard(
                              context,
                              vm,
                              user,
                              fontSize,
                            );
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

  Widget _buildUserHorizontalCard(
    BuildContext context,
    UsersAdminVM vm,
    AdminUserModel user,
    double fontSize,
  ) {
    final isSpecialUser = user.userType == 0 || user.userName == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: user.isBlocked
              ? Colors.redAccent
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () => _showUserDetailsDialog(context, vm, user, fontSize),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: isSpecialUser
                    ? Colors.orange.withOpacity(0.2)
                    : const Color(0xFFF4F7FE),
                backgroundImage:
                    (user.profileImageUrl != null &&
                        user.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child:
                    (user.profileImageUrl == null ||
                        user.profileImageUrl!.isEmpty)
                    ? Icon(
                        isSpecialUser
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: isSpecialUser ? Colors.orange : Colors.blue,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title: user.displayName,
                      fontWeight: FontWeight.bold,
                      size: fontSize - 2,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      title: user.email ?? user.phoneNumber ?? 'لا يوجد تواصل',
                      color: Colors.grey,
                      size: fontSize - 4,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: CustomText(
                            title: user.cityName ?? 'غير محدد',
                            size: fontSize - 4,
                          ),
                        ),
                      ],
                    ),
                    if (user.regionName != null) ...[
                      const SizedBox(height: 4),
                      CustomText(
                        title: user.regionName!,
                        color: Colors.grey,
                        size: fontSize - 5,
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      title: 'تاريخ الانضمام',
                      color: Colors.grey,
                      size: fontSize - 5,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      title: vm.formatDate(user.createdAt),
                      fontWeight: FontWeight.bold,
                      size: fontSize - 4,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetailsDialog(
    BuildContext context,
    UsersAdminVM vm,
    AdminUserModel user,
    double fontSize,
  ) {
    final PageController pageController = PageController();

    showDialog(
      context: context,
      builder: (ctx) {
        bool isAdsLoading = false;

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        double dialogWidth = screenWidth * 0.95;
        if (dialogWidth > 1100) dialogWidth = 1100;

        double dialogHeight = screenHeight * 0.95;
        if (dialogHeight > 800) dialogHeight = 800;

        return StatefulBuilder(
          builder: (context, setState) {
            return ListenableBuilder(
              listenable: vm,
              builder: (context, _) {
                final updatedUser = vm.users.firstWhere(
                  (u) => u.id == user.id,
                  orElse: () => user,
                );

                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(24),
                  child: Container(
                    width: dialogWidth,
                    height: dialogHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // الصفحة 1: بيانات المستخدم
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF4F7FE),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      title: 'ملف المستخدم',
                                      fontWeight: FontWeight.bold,
                                      size: fontSize,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundColor: const Color(
                                            0xFFF4F7FE,
                                          ),
                                          backgroundImage:
                                              (updatedUser.profileImageUrl !=
                                                      null &&
                                                  updatedUser
                                                      .profileImageUrl!
                                                      .isNotEmpty)
                                              ? NetworkImage(
                                                  updatedUser.profileImageUrl!,
                                                )
                                              : null,
                                          child:
                                              (updatedUser.profileImageUrl ==
                                                      null ||
                                                  updatedUser
                                                      .profileImageUrl!
                                                      .isEmpty)
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.blue,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                title: updatedUser.displayName,
                                                fontWeight: FontWeight.bold,
                                                size: fontSize + 2,
                                              ),
                                              if (updatedUser.fullName !=
                                                      null &&
                                                  updatedUser.userName != null)
                                                CustomText(
                                                  title:
                                                      '@${updatedUser.userName}',
                                                  color: Colors.grey,
                                                  size: fontSize - 2,
                                                ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      updatedUser.isBlocked
                                                      ? Colors.red.withOpacity(
                                                          0.1,
                                                        )
                                                      : Colors.green
                                                            .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: CustomText(
                                                  title:
                                                      updatedUser.isBlocked
                                                      ? 'حساب محظور'
                                                      : 'حساب نشط',
                                                  color:
                                                      updatedUser.isBlocked
                                                      ? Colors.red
                                                      : Colors.green,
                                                  size: fontSize - 4,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    const Divider(),
                                    const SizedBox(height: 16),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            'الإعلانات النشطة',
                                            updatedUser.numberOfProducts
                                                .toString(),
                                            Colors.blue,
                                            fontSize,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStatCard(
                                            'الإعلانات المنتهية',
                                            updatedUser.numberOfExpireProducts
                                                .toString(),
                                            Colors.orange,
                                            fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    _buildDetailRow(
                                      Icons.email_outlined,
                                      'البريد الإلكتروني',
                                      updatedUser.email ?? 'غير متوفر',
                                      fontSize - 2,
                                    ),
                                    _buildDetailRow(
                                      Icons.phone_outlined,
                                      'رقم الجوال',
                                      updatedUser.phoneNumber ?? 'غير متوفر',
                                      fontSize - 2,
                                    ),
                                    _buildDetailRow(
                                      Icons.location_city_outlined,
                                      'المدينة / المنطقة',
                                      '${updatedUser.cityName ?? 'غير محدد'} - ${updatedUser.regionName ?? 'غير محدد'}',
                                      fontSize - 2,
                                    ),
                                    _buildDetailRow(
                                      Icons.calendar_today_outlined,
                                      'تاريخ الانضمام',
                                      vm.formatDate(updatedUser.createdAt),
                                      fontSize - 2,
                                    ),

                                    if (updatedUser.bio != null &&
                                        updatedUser.bio!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAFBFF),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              title: 'النبذة التعريفية (Bio):',
                                              color: Colors.grey,
                                              size: fontSize - 4,
                                            ),
                                            const SizedBox(height: 4),
                                            CustomText(
                                              title: updatedUser.bio!,
                                              size: fontSize - 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 30),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                isAdsLoading = true;
                                              });
                                              pageController.animateToPage(
                                                1,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeInOut,
                                              );

                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 600,
                                                ),
                                                () {
                                                  if (context.mounted) {
                                                    setState(() {
                                                      isAdsLoading = false;
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.campaign_outlined,
                                              color: Colors.white,
                                            ),
                                            label: CustomText(
                                              title: 'عرض إعلاناته',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              size: fontSize - 2,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.current.primary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: vm.isActionLoading
                                                ? null
                                                : () =>
                                                      vm.toggleUserBlockStatus(
                                                        ctx,
                                                        updatedUser.id
                                                            .toString(),
                                                      ),
                                            icon: Icon(
                                              updatedUser.isBlocked
                                                  ? Icons.check_circle_outline
                                                  : Icons.block,
                                              color: Colors.white,
                                            ),
                                            label: vm.isActionLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : CustomText(
                                                    title: updatedUser.isBlocked
                                                        ? 'فك حظر المستخدم'
                                                        : 'حظر المستخدم',
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    size: fontSize - 2,
                                                  ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  updatedUser.isBlocked
                                                  ? Colors.green
                                                  : Colors.red,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // الصفحة 2: الإعلانات
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FE),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      pageController.animateToPage(
                                        0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    label: CustomText(
                                      title: 'رجوع',
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      size: fontSize - 2,
                                    ),
                                  ),
                                  const Spacer(),
                                  Expanded(
                                    flex: 2,
                                    child: CustomText(
                                      title:
                                          'إعلانات: ${updatedUser.displayName}',
                                      fontWeight: FontWeight.bold,
                                      size: fontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: isAdsLoading
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: AppColors.current.primary,
                                          ),
                                          const SizedBox(height: 16),
                                          CustomText(
                                            title:
                                                'جاري تحميل إعلانات المستخدم...',
                                            size: fontSize,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    )
                                  : AdsAdminScreen(
                                      initialUserId: updatedUser.id.toString(),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    double fontSize,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CustomText(
            title: value,
            color: color,
            fontWeight: FontWeight.bold,
            size: fontSize + 4,
          ),
          const SizedBox(height: 4),
          CustomText(
            title: title,
            color: Colors.black87,
            size: fontSize - 4,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value,
    double fontSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: CustomText(
              title: title,
              color: Colors.grey,
              size: fontSize - 2,
            ),
          ),
          Expanded(
            child: CustomText(
              title: value,
              fontWeight: FontWeight.bold,
              size: fontSize - 2,
            ),
          ),
        ],
      ),
    );
  }
}
