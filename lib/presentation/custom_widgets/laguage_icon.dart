import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/helpers_functions.dart';
import '../../../../configurations/localization/i18n.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../../configurations/resources/strings_manager.dart';
import '../../../../configurations/user_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:intl/intl.dart';

import '../../configurations/resources/assets_manager.dart';
import '../screens/common/common_view_model.dart';
import 'cust_svg_icons.dart';

class LanguageIcon extends StatefulWidget {
  static const String routeName = "LanguageIcon";

  const LanguageIcon({super.key});

  @override
  State<LanguageIcon> createState() => _LanguageIconState();
}

class _LanguageIconState extends State<LanguageIcon> {

  late CommonViewModel commonViewModel;
  // String indexOfSelectedLang = 'ar';

  @override
  void initState() {
    super.initState();
    commonViewModel = Provider.of<CommonViewModel>(context,listen: false);
    _loadLanguages().then((value) {
      setState(() {});
    });
  }

  Future<void> _loadLanguages() async {
    UserPreferences userPreferences = UserPreferences();

    var language = userPreferences.getString(key: AppStrings.languageKey, defaultValue: 'ar');

    commonViewModel.indexOfSelectedLang = language;
    // indexOfSelectedLang = language;
  }

  selectLanguage(String index){
    if(index == 'ar'){
      UserPreferences().saveString(key: AppStrings.languageKey,value:  'ar');
      commonViewModel.changeLanguage('ar');
    }else{
      UserPreferences().saveString(key: AppStrings.languageKey,value:  'en');
      commonViewModel.changeLanguage('en');
    }
  }

  OverlayEntry? _overlayEntry;

  Future<void> _toggleFilterMenu(BuildContext context) async {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) {

        return Stack(
          children: [
            // الخلفية المظللة
            GestureDetector(
              onTap: () => _toggleFilterMenu(context), // يغلق القائمة عند الضغط بالخارج
              child: Container(
                color: Colors.black.withOpacity(0.3), // لون شفاف للخلفية
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // القائمة نفسها
            Positioned(
              top: 65,
              left: commonViewModel.indexOfSelectedLang == 'en' ? null : 16,
              right: commonViewModel.indexOfSelectedLang == 'ar' ? null : 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: widthOfScreen(context) * 0.4,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: commonViewModel.locale == 'en'? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          debugPrint('ar');
                          selectLanguage('ar');
                          setState(() {
                            _overlayEntry!.remove();
                            _overlayEntry = null;
                          });
                        },
                        child: CusSvgIcons(iconAssetString:
                        IconAssets.languageArabic,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 3,),
                      Divider(),
                      SizedBox(height: 3,),
                      GestureDetector(
                        onTap: (){
                          debugPrint('en');
                          selectLanguage('en');
                          setState(() {
                            _overlayEntry!.remove();
                            _overlayEntry = null;
                          });
                        },
                        child: CusSvgIcons(iconAssetString:
                        IconAssets.languageEnglish,
                         size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    commonViewModel = Provider.of<CommonViewModel>(context);

    return GestureDetector(
      onTap: (){
        _toggleFilterMenu(context);
      },
      child: commonViewModel.indexOfSelectedLang == 'ar'
          ? CusSvgIcons(iconAssetString:
      IconAssets.flagAr,
        size: 30,
      ) : CusSvgIcons(iconAssetString:
      IconAssets.flagEn,
        size: 30,
      ) ,
    );
  }

}
