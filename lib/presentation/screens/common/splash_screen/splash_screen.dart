import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/helpers_functions.dart';
import '../../../../configurations/user_preferences.dart';
import '../../../../configurations/resources/assets_manager.dart';
import '../../../../configurations/resources/strings_manager.dart';
import '../../home/home_screen.dart';
import '../../home/main_wrapper_screen.dart';
import '../auth/login/login_view.dart';
import '../common_view_model.dart';


class SplashScreen extends StatefulWidget {
  static const String routeName = "/";

  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool isFirstOpenOnBoarding = true;

  late CommonViewModel commonViewModel;

  bool isFirsOpenApp = true;
  bool isSPlashingOpen = false;
  String branchId = '';
  String? loginToken;
  String? currentUserId;
  String? filledUserName;

  @override
  void initState() {
    super.initState();
    // intS();
    startTimer();
  }

  void startTimer() async {
    Timer(
      const Duration(seconds: 1),
      nextScreen,
    );
  }

  void nextScreen() async {
    UserPreferences userPreferences = UserPreferences();
    commonViewModel = Provider.of<CommonViewModel>(context,listen: false);

    loginToken = await userPreferences.getString(key: AppStrings.loginTokenKey, defaultValue: '');
    currentUserId = await UserPreferences().getString(key: AppStrings.userIdKey, defaultValue: '');
    filledUserName = await UserPreferences().getString(key: AppStrings.userNameKey, defaultValue: '');

    await commonViewModel.getLanguage();
    commonViewModel.setCurrentUserId(currentUserId ?? '');
    commonViewModel.setCurrentUserName(filledUserName ?? '');

    if(loginToken != '' && loginToken!.isNotEmpty && commonViewModel.currentUserId != '') {
      commonViewModel.setLoginIn(true);
    } else {
      commonViewModel.setLoginIn(false);
    }

    Navigator.of(context).pushNamedAndRemoveUntil(MainWrapperScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // splashViewModel = Provider.of<SplashViewModel>(context);

    return SafeArea(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
            //     image: DecorationImage(
            //       fit: BoxFit.fitWidth,
            //       image: AssetImage(
            //           ImageAssets.blueLogo
            //       ),
            //     ),
                color: Colors.white
            ),
            child: const SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Center(
              child: Image.asset(
                ImageAssets.logo2,
                width: widthOfScreen(context) * 0.6,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
