import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../configurations/helpers_functions.dart';
import '../../configurations/localization/i18n.dart';
import '../../configurations/resources/assets_manager.dart';
import 'cust_svg_icons.dart';
import 'custom_text.dart';
import 'custom_text_field.dart';

class CusPhoneField extends StatelessWidget {
  // 1. جعلنا القائمة ثابتة على مستوى الكلاس
  static const List<String> listOfItems = [
    // --- الدول العربية والأكثر استخداماً ---
    '+967', '+966', '+971', '+965', '+968', '+974', '+973', '+20', '+962',
    '+961', '+964', '+963', '+970', '+212', '+213', '+216', '+218', '+249',
    '+252', '+222', '+253', '+269', '+1', '+44', '+90', '+62', '+60', '+91',

    // --- بقية دول العالم ---
    '+7', '+27', '+30', '+31', '+32', '+33', '+34', '+36', '+39', '+40',
    '+41', '+43', '+45', '+46', '+47', '+48', '+49', '+51', '+52', '+53',
    '+54', '+55', '+56', '+57', '+58', '+61', '+63', '+64', '+65', '+66',
    '+81', '+82', '+84', '+86', '+92', '+93', '+94', '+95', '+98', '+211',
    '+220', '+221', '+223', '+224', '+225', '+226', '+227', '+228', '+229',
    '+230', '+231', '+232', '+233', '+234', '+235', '+236', '+237', '+238',
    '+239', '+240', '+241', '+242', '+243', '+244', '+245', '+246', '+247',
    '+248', '+250', '+251', '+254', '+255', '+256', '+257', '+258', '+260',
    '+261', '+262', '+263', '+264', '+265', '+266', '+267', '+268', '+290',
    '+291', '+297', '+298', '+299', '+350', '+351', '+352', '+353', '+354',
    '+355', '+356', '+357', '+358', '+359', '+370', '+371', '+372', '+373',
    '+374', '+375', '+376', '+377', '+378', '+379', '+380', '+381', '+382',
    '+383', '+385', '+386', '+387', '+389', '+420', '+421', '+423', '+500',
    '+501', '+502', '+503', '+504', '+505', '+506', '+507', '+508', '+509',
    '+590', '+591', '+592', '+593', '+594', '+595', '+596', '+597', '+598',
    '+599', '+670', '+672', '+673', '+674', '+675', '+676', '+677', '+678',
    '+679', '+680', '+681', '+682', '+683', '+685', '+686', '+687', '+688',
    '+689', '+690', '+691', '+692', '+850', '+852', '+853', '+855', '+856',
    '+880', '+886', '+960', '+972', '+975', '+976', '+977', '+992', '+993',
    '+994', '+995', '+996', '+998',
  ];

  final String? errorPhone;
  final String? phoneHint;
  final String? phoneCuntry;
  final TextEditingController? controller;
  final Function(String?) onDropdownChanged;
  final Function(String?) onTextChanged;

  const CusPhoneField({
    super.key,
    this.errorPhone,
    this.phoneHint,
    this.phoneCuntry,
    this.controller,
    required this.onDropdownChanged,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hint: phoneHint ?? '${S.of(context)!.enter} ${S.of(context)!.phone}',
      errorText: errorPhone,
      controller: controller,
      title: S.of(context)!.phone,
      type: TextInputType.phone,
      onChange: (value) {
        onTextChanged(value);
      },
      suffixIcon: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          _showModal(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min, // لتجنب الأخطاء في العرض
          children: [
            Container(
              height: 30,
              width: 1, // طول الخط الجانبي
              color: Colors.black26,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: isTablet(context) ? 80 : 50,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: CustomText(
                    title: phoneCuntry ?? '+967',
                    size: Theme.of(context).textTheme.bodySmall!.fontSize,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      prefixIcon: CusSvgIcons(
        iconAssetString: IconAssets.mobile,
      ),
    );
  }

  void _showModal(BuildContext context) {
    // 2. تعريف القائمة المفلترة والمتحكم داخل الدالة لتعمل مع الـ StatefulBuilder
    List<String> filteredList = List.from(listOfItems);
    TextEditingController searchController = TextEditingController();

    showMaterialModalBottomSheet(
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              height: heightOfScreen(context) * 0.85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: CustomText(
                        title: S.of(context)!.phoneCuy,
                        fontWeight: FontWeight.bold,
                        size: Theme.of(context).textTheme.bodyLarge!.fontSize,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey, height: 0.2),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CustomTextField(
                        controller: searchController,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              filteredList = List.from(listOfItems);
                              searchController.clear();
                            });
                          },
                          icon: const Icon(Icons.cancel_outlined),
                        ),
                        hint: S.of(context)!.search,
                        onChange: (value) {
                          // تحديث القائمة فوراً عند البحث
                          setState(() {
                            filteredList = _buildSearchList(value);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) =>
                        const Divider(height: 0.1),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              // 3. الحل هنا: إرسال القيمة من القائمة المفلترة وليس الأصلية
                              onDropdownChanged(filteredList[index]);
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0), // تكبير مساحة الضغط
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: CustomText(
                                      title: filteredList[index],
                                      size: Theme.of(context).textTheme.bodySmall!.fontSize,
                                    ),
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
              ),
            );
          },
        );
      },
    );
  }

  // 4. دالة بحث مبسطة وسريعة جداً
  List<String> _buildSearchList(String searchTerm) {
    if (searchTerm.trim().isEmpty) {
      return List.from(listOfItems);
    }
    // البحث يعتمد على احتواء النص
    return listOfItems.where((element) => element.contains(searchTerm)).toList();
  }
}