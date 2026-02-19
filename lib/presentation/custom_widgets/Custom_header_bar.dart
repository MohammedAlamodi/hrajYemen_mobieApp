import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/helpers_functions.dart';
import 'package:ye_hraj/presentation/custom_widgets/custom_text_field.dart';

import 'custom_text.dart';
// تأكد من استيراد ملف CustomText
// import 'path_to/custom_text.dart';

class CustomHeaderBar extends StatelessWidget {
  final String title;
  final bool showSearch;
  final bool showBack;
  final Function()? onBackTap;
  final Function(String)? onSearchChange;
  final TextEditingController? searchController;

  const CustomHeaderBar({
    Key? key,
    required this.title,
    required this.onSearchChange,
    this.showBack = true,
    this.showSearch = true,
    this.onBackTap,
    this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE1E8EF))),
      ),
      child: Column(
        children: [
          SizedBox(
            height: isTablet(context)? 90 : 50,
          ),

          // الصف العلوي: زر الرجوع والعنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             showBack?
                InkWell(
                onTap: onBackTap ?? () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE1E8EF)),
                  ),
                  child:  Icon(Icons.arrow_back_ios_new, size: isTablet(context)? 30 : 18, color: Colors.black),
                ),
              )
              :SizedBox(),

              // العنوان
              CustomText(
                title: title,
                // size: Theme,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F162A),
              ),


              SizedBox()
              // زر القائمة/الخيارات (يمكن تغييره حسب الحاجة)
              // Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     border: Border.all(color: const Color(0xFFE1E8EF)),
              //   ),
              //   child: const Icon(Icons.more_vert, size: 20, color: Colors.black),
              // ),
            ],
          ),

          SizedBox(
            height: 10,
          ),

          if (showSearch) ...[
            CustomTextField(
              controller: searchController,
              textAlign: TextAlign.right,
              hint: 'ابحث هنا...',
              prefixIcon: Icon(Icons.search, color: Color(0xFFA9A9A9)),
              onChange: onSearchChange,
            ),
          ]
        ],
      ),
    );
  }
}