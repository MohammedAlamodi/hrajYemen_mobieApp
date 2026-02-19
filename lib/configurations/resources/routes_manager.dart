import 'package:flutter/material.dart';
import '../../presentation/screens/common/auth/forget_password_email/forget_password_email_view.dart';
import '../../presentation/screens/common/auth/forget_password_email/forget_password_phone_view.dart';
import '../../presentation/screens/common/auth/forget_password_email/otp_for_email.dart';
import '../../presentation/screens/common/auth/login/login_view.dart';
import '../../presentation/screens/common/auth/singup/phoneVirev.dart';
import '../../presentation/screens/common/auth/singup/singup_view.dart';
import '../../presentation/screens/common/splash_screen/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/home/main_wrapper_screen.dart';

class MyRoutes {
  static var routes = <String, WidgetBuilder>{
    "/": (ctx) => const SplashScreen(),
    LoginScreen.routeName: (ctx) => const LoginScreen(),
    RegistrationScreen.routeName: (ctx) => const RegistrationScreen(),
    OtpPage.routeName: (ctx) => OtpPage(),
    ForgetPasswordEmailView.routeName: (ctx) => ForgetPasswordEmailView(),
    OtpForEmailScreen.routeName: (ctx) => OtpForEmailScreen(),
    HomeScreen.routeName: (ctx) => HomeScreen(),
    MainWrapperScreen.routeName: (ctx) => MainWrapperScreen(),
    ForgetPasswordPhoneView.routeName: (ctx) => ForgetPasswordPhoneView(),

// OnBoardingScreen.routeName: (ctx) => const OnBoardingScreen(),
  };

  static Route<BuildContext>? getRoutes(RouteSettings settings) {
    var builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        settings: settings,
        builder: builder,
      );
    }
    return null;
  }
}
