import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../configurations/helpers_functions.dart';
import '../../../configurations/localization/i18n.dart';
import '../../../configurations/resources/app_colors.dart';
import '../custom_text.dart';
import '../custom_text_field.dart';


class CustomBottomSheetWithSearch extends StatelessWidget {
  final BuildContext cotx;
  final String bottomSheetTitle;
  final String hint;
  final String? title;
  final Color? borderColor;
  final String? errorTitle;
  final String? titleOutOfCard;
  final double? padding;
  final double? withOfName;
  final List listOfItems;
  final Function(String? name, int? id,
      {int? indexOfSelectedItem, dynamic selectedItem})? onItemTap;
  final double? borderRadius;
  final double? size;

  List? _filteredListOfItems;

  final TextEditingController textController = TextEditingController();

  CustomBottomSheetWithSearch({
    super.key,
    required this.cotx,
    required this.bottomSheetTitle,
    required this.hint,
    this.title,
    this.borderColor,
    this.withOfName,
    this.titleOutOfCard,
    this.errorTitle,
    this.size,
    this.padding,
    required this.listOfItems,
    required this.onItemTap,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (titleOutOfCard != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: CustomText(
                title: titleOutOfCard,
                textAlign: TextAlign.start,
                // size: Theme.of(context).textTheme.bodySmall!.fontSize! ,
              ),
            )
          else
            const SizedBox(),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());

              _showModal(context);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: padding ?? 8),
              height: 55,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: errorTitle != null ? Colors.redAccent : title!=null ? AppColors.current.primary: borderColor ?? Colors.grey),
                  borderRadius: BorderRadius.circular(borderRadius!),
                  color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                      width: withOfName,
                      child: CustomText(
                        title: title ?? hint,
                        size: size ??
                            Theme.of(context).textTheme.bodySmall!.fontSize,
                        maxLines: 1,

                        color: title!=null?Colors.black : Colors.grey,
                        // fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Icon(Icons.arrow_drop_down_sharp)),
                ],
              ),
            ),
          ),
          if (errorTitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    title: errorTitle,
                    color: const Color(0xFF961C12),
                    textAlign: TextAlign.start,
                    size: Theme.of(context).textTheme.bodySmall!.fontSize!,
                  ),
                ],
              ),
            )
          else
            const SizedBox(),
        ],
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
              borderRadius: BorderRadius.circular(borderRadius!),
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
                        title: bottomSheetTitle,
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
                                textController.clear();
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
                          itemCount: (_filteredListOfItems != null &&
                                  _filteredListOfItems!.isNotEmpty)
                              ? _filteredListOfItems!.length
                              : listOfItems.length,
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
                                    onItemTap!(
                                      _filteredListOfItems != null
                                          ? _filteredListOfItems![index].name
                                          : listOfItems[index].name,
                                      _filteredListOfItems != null
                                          ? _filteredListOfItems![index].id
                                          : listOfItems[index].id,
                                      indexOfSelectedItem:
                                          _filteredListOfItems != null
                                              ? listOfItems.indexOf(
                                                  _filteredListOfItems![index])
                                              : index,
                                      selectedItem: _filteredListOfItems != null
                                          ? _filteredListOfItems![index]
                                          : listOfItems[index],
                                    );
                                    // debugPrint('************ ${
                                    //     (_filteredListOfItems !=
                                    //         null &&
                                    //         _filteredListOfItems!.isNotEmpty)
                                    //         ? _filteredListOfItems![index].name
                                    //         : listOfItems[index].name
                                    // }');
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
      child: CustomText(
          title: listOfCities[index].name,
          size: Theme.of(context).textTheme.bodySmall!.fontSize,
          textAlign: TextAlign.start),
    );
  }

  //9
  List _buildSearchList(String userSearchTerm) {
    List searchList = [];

    for (int i = 0; i < listOfItems.length; i++) {
      String name = listOfItems[i].name;
      List<String> searchLowerSplit = userSearchTerm.split(' ');
      int coun = 0;
      for (var i in searchLowerSplit) {
        if (name.contains(i)) {
          coun++;
        }
      }
      if (coun == searchLowerSplit.length) {
        searchList.add(listOfItems[i]);
      }
    }
    return searchList;
  }
}
