import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/presentation/screens/profile/settings_screen.dart';
import '../../../configurations/resources/app_colors.dart';
import '../../../model/user_model.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text.dart';
import '../common/common_view_model.dart';
import '../my_ads/my_ad_view_model.dart';
import '../my_ads/my_ads_screen.dart';
import 'custom_widgets/menu_tile.dart';
import 'guest_screen.dart';
import 'profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileViewModel vm = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.current.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. الهيدر (مشترك)
            _buildHeader(),

            // 2. المحتوى (متغير حسب الحالة)
            Expanded(
              child: Consumer<CommonViewModel>(
                builder: (context, vm, child) {
                  return _buildUserView(context, vm);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- الهيدر ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // زر القائمة (وهمي للتصميم)
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE1E8EF)), shape: BoxShape.circle),
          //   child: const Icon(Icons.more_vert, color: Color(0xFF0F162A), size: 20),
          // ),
          Expanded(
            child: Center(
              child: const CustomText(
                title: 'الملف الشخصي',
                size: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F162A),
              ),
            ),
          ),

          // زر الرجوع أو الإشعارات
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE1E8EF)),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Color(0xFF0F162A),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // --- واجهة المستخدم (User View) ---
  Widget _buildUserView(BuildContext context, CommonViewModel vm) {
    final user = vm.user!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 1. بطاقة التعريف
          _buildProfileCard(user),

          const SizedBox(height: 16),

          // 2. الإحصائيات (إعلاناتي الحالية / المنتهية)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    MyAdViewModel vm = Provider.of<MyAdViewModel>(context, listen: false);
                    vm.changeTab(0);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // ✅ نمرر المنتج الحقيقي هنا
                        builder: (_) => MyAdsScreen(curIndex: 0,),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    context: context,
                    count: user.activeAdsCount ?? 0,
                    label: 'إعلاناتي الحالية',
                    iconColor: AppColors.current.primary,
                    icon: Icons.open_in_browser, // أيقونة إعلانات
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    MyAdViewModel vm = Provider.of<MyAdViewModel>(context, listen: false);
                    vm.changeTab(0);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyAdsScreen(curIndex: 1,),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    context: context,
                    count: user.expiredAdsCount ?? 0,
                    iconColor: Colors.blueGrey,
                    label: 'إعلاناتي المنتهية',
                    // استبدلنا المفضلة بهذا
                    icon: Icons.done_all_outlined, // أيقونة أرشيف/منتهي
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. القائمة
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E8EF)),
            ),
            child: Column(
              children: [
                MenuTile(
                  icon: Icons.settings_outlined,
                  title: 'الإعدادات',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                MenuTile(
                  icon: Icons.wallet,
                  title: 'دفع العمولة',
                  onTap: () {},
                ),
                _buildDivider(),
                MenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'الشروط والسياسات',
                  onTap: () {},
                ),
                _buildDivider(),
                MenuTile(
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  onTap: () => vm.logout(context),
                  isDestructive: false, // يمكن جعلها حمراء لو أردت
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const CustomText(
            title: 'الإصدار 1.0.0',
            size: 12,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // Widgets مساعدة (للتنظيم)
  // -----------------------------------------------------------

  Widget _buildProfileCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // الصورة
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF3F4F6),
              image: DecorationImage(
                image: NetworkImage(user.profileImageUrl ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // البيانات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title: user.fullName,
                  size: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F162A),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_in_talk_outlined,
                      size: 16,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      title: user.phoneNumber,
                      size: 14,
                      color: const Color(0xFF63748A),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.current.blue,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      title: user.location,
                      size: 14,
                      color: const Color(0xFF63748A),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // زر تعديل
          const Icon(Icons.edit_square, color: Color(0xFF2462EB), size: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required int count,
    required String label,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // الأيقونة في دائرة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          // الرقم
          Center(
            child: CustomText(
              title: '$count',
              size: Theme.of(context).textTheme.bodyLarge!.fontSize! + 3,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F162A),
            ),
          ),
          const SizedBox(height: 4),
          // العنوان
          Center(
            child: CustomText(
              title: label,
              size: Theme.of(context).textTheme.bodySmall!.fontSize!,
              color: const Color(0xFF63748A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile2({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFEEF6FF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive
              ? Colors.red
              : const Color(0xFF2462EB), // لون أحمر للحذف
        ),
      ),
      title: CustomText(
        title: title,
        size: 15,
        fontWeight: FontWeight.w600,
        color: isDestructive ? Colors.red : const Color(0xFF0F162A),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF9CA2AE),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 60);
  }
}
