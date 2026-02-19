// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class AppColors {
  static AppColors? _current;

  static AppColors get current => _current ?? _defaultLightColors;

  static set current(value) => _current = value;

  AppColors({
    required this.primary,
    required this.primary50,
    required this.primary200,
    // required this.primary100,
    // required this.primary200,
    // required this.primary300,
    // required this.primary400,
    // required this.primary600,
    // required this.primary700,
    // required this.primary800,
    // required this.primary900,

    required this.secondary,

    required this.grey,
    required this.blue,
    required this.blackGrey,
    required this.error,
    required this.warning,
    required this.appBackground,

    required this.success,
  });

  Color primary;
  Color primary200;
  Color primary50;
  // Color primary100;
  // Color primary200;
  // Color primary300;
  // Color primary400;
  // Color primary600;
  // Color primary700;
  // Color primary800;
  // Color primary900;

  Color secondary;

  Color grey;
  Color blackGrey;
  Color blue;
  Color error;
  Color warning;

  Color success;
  Color appBackground;
}
// LinearGradient(
// begin: Alignment(1.00, 1.00),
// end: Alignment(0.00, 1.00),
// colors: [const Color(0xFF0D9488), const Color(0x000D9488)],
// )
var _defaultLightColors = AppColors(
  primary: const Color(0xFF0D9387),
  primary200: const Color(0xFF00C8B3),
  primary50: const Color(0xFFE5F3FF),

  blackGrey: const Color(0xFF0F162A),
  // primary100: const Color(0xffFFCEB0),
  // primary200: const Color(0xffFFB68A),
  // primary300: const Color(0xffFF9454),
  // primary400: const Color(0xffFF8033),
  // primary600: const Color(0xffE85700),
  // primary700: const Color(0xffB54400),
  // primary800: const Color(0xff8C3500),
  // primary900: const Color(0xff6B2800),

  grey: Colors.grey,

  error: const Color(0xffE54545),

  blue: const Color(0xFF2462EB),

  warning: const Color(0xffFF8800),

  secondary: const Color(0xff454545),
  appBackground: const Color(0xFFFBFBFB),

  success: const Color(0xff0055f8),
);