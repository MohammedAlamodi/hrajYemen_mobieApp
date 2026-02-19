import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ye_hraj/presentation/screens/home/home_view_model.dart';
import 'configurations/helpers_functions.dart';
import 'configurations/localization/i18n.dart';
import 'configurations/user_preferences.dart';
import 'configurations/resources/app_colors.dart';
import 'configurations/resources/routes_manager.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'firebase_options.dart';
import 'presentation/screens/common/auth/login/login_view_model.dart';
import 'presentation/screens/common/common_view_model.dart';
import 'presentation/screens/favorites/favorites_view_model.dart';
import 'presentation/screens/home/main_wrapper_view_model.dart';
import 'presentation/screens/my_ads/my_ad_view_model.dart';
import 'presentation/screens/products/add_products/add_ad_view_model.dart';
import 'presentation/screens/products/product_details_view_model.dart';
import 'presentation/screens/products/product_display_view_model.dart';
import 'presentation/screens/profile/profile_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await UserPreferences().init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MultiProvider(providers: _providers, child: const MyApp()));
  });
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await UserPreferences().init();
//   // Provider.debugCheckInvalidValueType = null;
//   runApp(MultiProvider(providers: _providers, child: const MyApp()));
// }

final List<SingleChildWidget> _providers = [
  ChangeNotifierProvider(create: (ctx) => CommonViewModel()),
  ChangeNotifierProvider(create: (ctx) => LoginViewModel()),
  ChangeNotifierProvider(create: (ctx) => MainWrapperViewModel()),
  ChangeNotifierProvider(create: (ctx) => ProductDetailsViewModel()),
  ChangeNotifierProvider(create: (ctx) => ProductDisplayViewModel()),
  ChangeNotifierProvider(create: (ctx) => HomeViewModel()),
  ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
  ChangeNotifierProvider(create: (_) => ProfileViewModel()),
  ChangeNotifierProvider(create: (_) => AddAdViewModel()),
  ChangeNotifierProvider(create: (_) => MyAdViewModel()),
  // ChangeNotifierProvider(create: (ctx) => RegistrationViewModel()),
];

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a blue toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: AppColors.current.primary),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }
class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    CommonViewModel commonViewModel =Provider.of<CommonViewModel>(context);
    debugPrint('*****locale ${commonViewModel.locale}');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      locale: Locale(commonViewModel.locale, ""),
      // locale: const Locale('ar', ""),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeListResolutionCallback:
      S.delegate.listResolution(fallback: const Locale('ar', '')),
      theme: ThemeData(
        fontFamily: 'Expo Arabic',
        primarySwatch: MaterialColor(AppColors.current.primary.value,
            getColorsSwatch(AppColors.current.primary)),
        // primaryColor: AppColors.current.primary,
        // primaryColorLight: AppColors.current.primary,
        // indicatorColor: AppColors.current.primary,
        // brightness: Brightness.light,
        // hintColor: Colors.grey,
        textTheme: TextTheme(
          bodySmall: TextStyle(
              fontSize: setFontSize(context,
                  ifPortrait: isTablet(context) ? 0.024 : 0.035,
                  notPortrait: isTablet(context) ? 0.026 : 0.036),
              color: Colors.black),
          bodyMedium: TextStyle(
              fontSize: setFontSize(context,
                  ifPortrait: isTablet(context) ? 0.03 : 0.04,
                  notPortrait: isTablet(context) ? 0.033 : 0.042),
              color: Colors.black),
          bodyLarge: TextStyle(
              fontSize: setFontSize(context,
                  ifPortrait: isTablet(context) ? 0.032 : 0.044,
                  notPortrait: isTablet(context) ? 0.032 : 0.046),
              color: Colors.black),
        ),
      ),
      routes: MyRoutes.routes,
      onGenerateRoute: MyRoutes.getRoutes,
    );
  }

  setFontSize(context,
      {required double ifPortrait, required double notPortrait}) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? widthOfScreen(context) * ifPortrait
        : heightOfScreen(context) * notPortrait;
  }
}

Map<int, Color> getColorsSwatch(Color color) {
  final hslColor = HSLColor.fromColor(color);
  final lightness = hslColor.lightness;

  final lowDivisor = 6;

  final highDivisor = 5;

  final lowStep = (1.0 - lightness) / lowDivisor;
  final highStep = lightness / highDivisor;

  return {
    50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
    100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
    200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
    300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
    400: (hslColor.withLightness(lightness + lowStep)).toColor(),
    500: (hslColor.withLightness(lightness)).toColor(),
    600: (hslColor.withLightness(lightness - highStep)).toColor(),
    700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
    800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
    900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
  };
}
