import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/user_preferences.dart';
import 'package:ye_hraj/presentation/screens/common/auth/login/login_view_model.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_text.dart';
import '../admin_stats/dashboard_admin_screen.dart';
import '../ads_admin/ads_admin_screen.dart';
import '../categories_admin/categories_admin_screen.dart';
import '../cities_and_region/cities_admin_screen.dart';
import '../users_admin/users_admin_screen.dart';

// هنا تقوم باستدعاء الشاشات الإدارية التي سنبنيها
// import 'categories_admin_screen.dart';
// import 'cities_admin_screen.dart';
// import 'users_admin_screen.dart';
// import 'ads_admin_screen.dart';

class AdminMainScreen extends StatefulWidget {
  static const String routeName = "/AdminMainScreen";

  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _adminScreens = [
    const DashboardAdminScreen(),
    const CategoriesAdminScreen(),
    const CitiesAdminScreen(),
    const UsersAdminScreen(),
    AdsAdminScreen()
  ];

  @override
  Widget build(BuildContext context) {
    // فحص عرض الشاشة
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: isDesktop
          ? null // لا نحتاج AppBar في الشاشات الكبيرة
          : AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: AppColors.current.primary),
              title: CustomText(
                title: _getTitle(_selectedIndex),
                fontWeight: FontWeight.bold,
              ),
              centerTitle: true,
              elevation: 0,
            ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      body: Row(
        children: [
          if (isDesktop)
            Container(width: 260, color: Colors.white, child: _buildSidebar()),
          Expanded(
            child: Column(
              children: [
                if (isDesktop)
                  Container(
                    height: 80,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          title: _getTitle(_selectedIndex),
                          size: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  title: 'المدير العام',
                                  size: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.fontSize!,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () async {
                                    await UserPreferences().logout(context);
                                  },
                                  child: CustomText(
                                    title: 'تسجيل الخروج',
                                    size:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall!.fontSize! -
                                        6,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 15),
                            CircleAvatar(
                              backgroundColor: AppColors.current.primary,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _adminScreens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        const SizedBox(height: 40),
        CustomText(
          title: 'أدمن حراج حضرموت',
          size: Theme.of(context).textTheme.bodySmall!.fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.current.primary,
        ),
        const SizedBox(height: 40),
        _buildMenuItem(0, 'الرئيسية', Icons.home_filled),
        _buildMenuItem(1, 'إدارة الفئات', Icons.category_outlined),
        _buildMenuItem(2, 'المدن والمناطق', Icons.location_city_outlined),
        _buildMenuItem(3, 'المستخدمين', Icons.people_outline),
        _buildMenuItem(4, 'الإعلانات', Icons.campaign_outlined),
      ],
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.current.primary : Colors.grey,
      ),
      title: CustomText(
        title: title,
        size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
        color: isSelected ? AppColors.current.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selected: isSelected,
      selectedTileColor: AppColors.current.primary.withOpacity(0.1),
      onTap: () {
        setState(() => _selectedIndex = index);
        // إغلاق الـ Drawer في شاشات الجوال
        if (MediaQuery.of(context).size.width <= 900 &&
            Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
      },
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'لوحة الإحصائيات';
      case 1:
        return 'إدارة الفئات الرئيسية والفرعية';
      case 2:
        return 'إدارة المدن والمناطق';
      case 3:
        return 'سجل المستخدمين';
      case 4:
        return 'الإعلانات والمشاهدات';
      default:
        return 'الإدارة';
    }
  }
}
