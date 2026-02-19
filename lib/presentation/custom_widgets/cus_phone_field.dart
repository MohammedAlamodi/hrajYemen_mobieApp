import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../configurations/helpers_functions.dart';
import '../../configurations/localization/i18n.dart';
import '../../configurations/resources/assets_manager.dart';
import 'cust_svg_icons.dart';
import 'custom_text.dart';
import 'custom_text_field.dart';

class CusPhoneField extends StatelessWidget {
  final List<String> listOfItems = ['+967', '+966', '+1', '+971', '+44'];

  List? _filteredListOfItems = ['+967', '+966', '+1', '+971', '+44'];

  TextEditingController? textController = TextEditingController();

  String? errorPhone;
  String? phoneCuntry;
  TextEditingController? controller;
  final Function(String?) onDropdownChanged;
  final Function(String?) onTextChanged;

  CusPhoneField({
    super.key,
    this.errorPhone,
    this.phoneCuntry,
    this.controller,
    required this.onDropdownChanged,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hint: '${S.of(context)!.enter} ${S.of(context)!.phone}',
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
          children: [
            Container(
              height: 30,
              width: 1, // طول الخط الجانبي
              color: Colors.black26,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: isTablet(context)? 80 : 50,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: CustomText(
                    title: phoneCuntry,
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

  _showModal(context) {
    return showMaterialModalBottomSheet(
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) {
          //3
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: heightOfScreen(context) * 0.85,
            decoration: BoxDecoration(
              // border: Border.all(width: 1, color: borderColor ?? AppColors.current.primary),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: CustomText(
                        title: S.of(context)!.phoneCuy,
                        fontWeight: FontWeight.bold,
                        size: Theme.of(context).textTheme.bodyLarge!.fontSize,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 0.2,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: CustomTextField(
                          controller: textController,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _filteredListOfItems = _buildSearchList('');
                                textController!.clear();
                              });
                            },
                            icon: const Icon(Icons.cancel_outlined),
                          ),
                          hint: S.of(context)!.search,
                          onChange: (value) {
                            //4
                            setState(() {
                              _filteredListOfItems = _buildSearchList(value);
                            });
                          },
                        )),
                    Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.all(0),
                          itemCount: _filteredListOfItems!.length,
                          separatorBuilder: (context, int ing) {
                            return const Divider(
                              height: 0.1,
                            );
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(

                                  //6
                                  child: (_filteredListOfItems != null &&
                                          _filteredListOfItems!.isNotEmpty)
                                      ? _showBottomSheetWithSearch(
                                          context, index, _filteredListOfItems!)
                                      : _showBottomSheetWithSearch(
                                          context, index, listOfItems),
                                  onTap: () {
                                    onDropdownChanged(listOfItems[index]);
                                    Navigator.of(context).pop();
                                  }),
                            );
                          }),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }

  //8
  Widget _showBottomSheetWithSearch(context, int index, List listOfCities) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomText(
              title: listOfCities[index],
              size: Theme.of(context).textTheme.bodySmall!.fontSize,
            ),
          ),
        ],
      ),
    );
  }

  //9
  List _buildSearchList(String userSearchTerm) {
    List searchList = [];

    for (int i = 0; i < listOfItems.length; i++) {
      String name = listOfItems[i];
      List<String> searchLowerSplit = userSearchTerm.split(' ');
      int coun = 0;
      for (var i in searchLowerSplit) {
        if (name.contains(i)) {
          coun++;
        }
      }
      if (coun == searchLowerSplit.length && coun != 0) {
        debugPrint('=======coun == searchLowerSplit.length && coun != 0');
        searchList.add(listOfItems[i]);
      }
    }
    return searchList;
  }
}
