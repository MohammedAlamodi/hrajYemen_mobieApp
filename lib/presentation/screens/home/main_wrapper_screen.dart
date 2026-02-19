import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/model/seller_model.dart';

import '../../../configurations/data/end_points_manager.dart';
import '../../custom_widgets/Custom_animated_nav_bar.dart';
import '../chat/chat_list_screen.dart';
import '../chat/chat_screen.dart';
import '../common/common_view_model.dart';
import '../favorites/favorites_screen.dart';
import '../products/add_products/add_ad_screen.dart';
import '../profile/guest_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';
import 'main_wrapper_view_model.dart'; // تأكد من وجود Provider

class MainWrapperScreen extends StatelessWidget {
  static const String routeName = '/mainWrapper';
  late final CommonViewModel commonViewModel;
  MainWrapperScreen({super.key});

  // قائمة الصفحات (باستثناء صفحة إضافة إعلان)
   List<Widget> _pages = [
    HomeScreen(),
    FavoritesScreen(), // صفحة 1
    ChatListScreen(),      // صفحة 2
    ProfileScreen(),   // صفحة 3
  ];

  @override
  Widget build(BuildContext context) {
    commonViewModel = Provider.of<CommonViewModel>(context);
    _pages = [
      HomeScreen(),
      FavoritesScreen(), // صفحة 1
      commonViewModel.isLoggedIn
          ? ChatListScreen()
          : GuestScreen(), // صفحة 2
      commonViewModel.isLoggedIn ? ProfileScreen() : GuestScreen(), // صفحة 2

    ];

    return ChangeNotifierProvider(
      create: (_) => MainWrapperViewModel(),
      child: Consumer<MainWrapperViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            // نستخدم Stack لضمان أن الناف بار يظهر فوق المحتوى
            // أو يمكن استخدام bottomNavigationBar الخاص بالسكافولد،
            // لكن هنا سنستخدم طريقتك المخصصة للتحكم الكامل
            body: Stack(
              children: [
                // 1. المحتوى (الصفحات)
                Positioned.fill(
                  child: IndexedStack(
                    index: viewModel.currentIndex,
                    children: _pages,
                  ),
                ),

                // 2. شريط التنقل السفلي
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomAnimatedNavBar(
                    selectedIndex: viewModel.currentIndex,

                    // عند الضغط على الأيقونات العادية
                    onItemTapped: (index) {
                      viewModel.changePage(index);
                    },

                    // عند الضغط على زر الإضافة (الوسط)
                    onAddAdTapped: () {
                      // ننتقل لصفحة جديدة كاملة بدلاً من تغيير التبويب
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddAdScreen()),
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
}