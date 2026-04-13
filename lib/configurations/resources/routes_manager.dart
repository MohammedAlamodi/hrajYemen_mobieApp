import 'package:flutter/material.dart';
import '../../presentation/screens/admin_web/login/auth_wrapper.dart';
import '../../presentation/screens/common/auth/forget_password_email/forget_password_email_view.dart';
import '../../presentation/screens/common/auth/forget_password_email/forget_password_phone_view.dart';
import '../../presentation/screens/common/auth/forget_password_email/otp_for_email.dart';
import '../../presentation/screens/common/auth/login/login_view.dart';
import '../../presentation/screens/common/auth/register/phoneVirev.dart';
import '../../presentation/screens/common/auth/register/register_view.dart';
import '../../presentation/screens/common/splash_screen/splash_screen.dart';
import '../../presentation/screens/customer/home/home_screen.dart';
import '../../presentation/screens/customer/home/main_wrapper_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MyRoutes {
  static var routes = <String, WidgetBuilder>{
    "/": (ctx) =>  kIsWeb ? AuthWrapper() : SplashScreen(),
    LoginScreen.routeName: (ctx) => const LoginScreen(),
    RegisterScreen.routeName: (ctx) => const RegisterScreen(),
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
