import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../custom_widgets/custom_text.dart';
import '../../../../custom_widgets/custom_text_field.dart';
import '../../../common/common_view_model.dart';
import '../home_view_model.dart';
import 'filter_bottom_sheet.dart';

class HomeCustomAppBar extends StatelessWidget {
  late CommonViewModel commonViewModel;
  late HomeViewModel homeViewModel;

  HomeCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    commonViewModel = Provider.of<CommonViewModel>(context);
    homeViewModel = Provider.of<HomeViewModel>(context);

    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 20,),
      color: Colors.white,
      child: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //    CustomText(
          //       title: commonViewModel.isLoggedIn ? 'مرحبا بك ${commonViewModel.currentUserName}' : '  مرحبا بك نورتنا',
          //       fontWeight: FontWeight.bold,
          //    ),
          //
          //     // زر الإشعارات
          //     Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         border: Border.all(color: const Color(0xFFE1E8EF)),
          //       ),
          //       child: const Icon(Icons.notifications_outlined, size: 20),
          //     ),
          //   ],
          // ),

          const SizedBox(height: 16),
          // حقل البحث
          Row(
            children: [
              // إعداد زر الفلتر في واجهة المنتجات (ProductsScreen)
              Expanded(
                child: CustomTextField(
                  textAlign: TextAlign.right,
                  hint: 'ابحث عن سيارة، جوال، شقة...',
                  controller: homeViewModel.sherTextCont,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  labelText: 'ابحث عن سيارة، جوال، شقة...',
                  onFileSubmitted: (value) {
                      homeViewModel.onSearchTextChanged();
                  },
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () async {
                      if (homeViewModel.cities.isEmpty) {
                        homeViewModel.fetchCities();
                      }
                      // 1. فتح نافذة الفلتر وانتظار النتيجة
                      await FilterBottomSheet.show(context, homeViewModel);
                    },
                  ),
                  // شارة حمراء بعدد الفلاتر النشطة (المدينة/المنطقة/السعر)
                  if (homeViewModel.activeFilterCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${homeViewModel.activeFilterCount}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}