// ignore_for_file: unnecessary_null_comparison

import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class S implements WidgetsLocalizations {
  const S();

  static S? current;
  static const GeneratedLocalizationsDelegate delegate =
      GeneratedLocalizationsDelegate();

  String get login => "تسجيل الدخول";

  String get logout => 'تسجيل الخروج';

  String get add => "إضافة";

  String get all => "الكل";

  String get enter => "أدخل";

  String get hal => "هل";

  String get remove => " إزالة ";

  String get cancel => "إلغاء";

  String get confirmRemoval => "تأكيد الإزالة";

  String get confirmRemovalMessage => "هل أنت متأكد أنك تريد إزالة ";

  String get errorInLogin => "خطأ في تسجيل الدخول";

  String get errorHap => "حدث خطأ";

  String get anErrorOccurred =>
      "خطأ في الأتصال بالسيرفر ، تأكد من اتصالك بالانترنت";

  String get password => "كلمة المرور";

  String get userName => "اسم المستخدم";

  String get requiredFiled => "حقل مطلوب";

  String get errorInInout => "خطأ في الادخال";

  String get inputError => "يوجد خطأ في احد الحقول";

  String get confirmPasswordError => "كلمة المرور غير متطابقه";

  String get emailValid => "خطأ في تنسيق الايميل";

  String get forgetPassword => "نسيت كلمة المرور";

  String get sureOTP => "تأكيد رمز التحقق";

  String get conf => "تحقق";

  String get resentOTP => "إعادة الإرسال";

  String get doYouRememberPassword => "هل تذكرت كلمة مرورك ؟   ";

  String get thereIsNoOTP => "لم يصلك رمز التحقق على البريد ؟  ";

  String get enterOTP => "يرجى إدخال رمز التحقق المرسل إلى بريدك الإلكتروني لاستكمال عملية تسجيل الحساب";

  String get enterEmail => "من فضلك، يرجى إدخال البريد الإلكتروني المرتبط بحسابك";

  String get loginToYourAccounts => "سجل دخولك للوصول إلى حسابك وبدء استخدام التطبيق!";

  String get suingToYourAccounts => "أنشئ حسابك الآن، وحدد نوع الحساب الذي يناسبك للوصول السريع إلى خدماتنا وبدء طلباتك بسهولة!";

  String get enterPhone => "من فضلك، يرجى إدخال رقم الجوال المرتبط بحسابك";

  String get restPassword => "أستعادة كلمة المرور";

  String get orRestBy => "او أستعادة الحساب عن طريق";

  String get orRestByPhoneNum => "رقم الجوال المرتبط بالحساب";

  String get orRestByEmailNum => "البريد الإلكتروني المرتبط بالحساب";

  String get yes => "نعم";

  String get yesImSure => "نعم متآكد";

  String get no => "لا";

  String get search => "بحث..";

  String get reTry => "المحاولة مره اخرى";

  String get dntHaveAccount => "ليس لديك حساب ؟";

  String get youWantToHaveAccount => "ليس لديك حساب ؟";

  String get getAccountNew => "تقديم طلب";

  String get youHaveAccount => "لديك حساب بالفعل ؟";

  String get sinUpNow => "سجل الان";

  String get sinUpNow2 => "إنشاء حساب";

  String get createAccount => "إنشاء حساب جديد";

  String get createAnAccount => "إنشاء حساب";

  String get email => "الايميل";

  String get email_ => "البريد الألكتروني";

  String get confPassword => "تأكيد كلمة المرور";

  String get role => "التسجيل كـ";

  String get name => "الاسم";

  String get yourName => "اسمك";

  String get yourEmail => "بريدك الألكتروني";

  String get foreignName => "اسم ثانوي";

  String get contactInfo => "جهة اتصال";

  String get address => "العنوان";

  String get phone => "رقم الجوال";

  String get phoneCuy => "أختر رمز بلدك";

  String get logo => "الصورة";

  String get register => "التسجيل";

  String get weak => "ضعيفة";

  String get medium => "متوسطة";

  String get strong => "قوية";

  String get processDone => "تمت العملية";

  String get registerDone => "تم تسجيل حسابك بنجاح";

  String get goToLogin => "أذهب لتسجيل الدخول";

  String get loading => "جاري التحميل..";

  String get homeScreen => "الرئيسية";

  String get noProducts => "لايوجد بيانات";

  String get offerTotal => "الاجمالي";

  String get details => "التفاصيل";

  String get offerTotalAmount => "المبلغ الكلي";

  String get startDate => "تاريخ البداية :";

  String get endDate => "تاريخ الانتهاء :";

  String get discount => "الخصم :";

  String get showDetails => "عرض التفاصيل >";

  String get available => "متاح";

  String get notAvailable => "غير متاح";

  String get emailOrPhone => "البريد الإلكتروني أو رقم الجوال";

  static S? of(BuildContext context) => Localizations.of<S>(context, S);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  // TODO: implement reorderItemDown
  String get reorderItemDown => throw UnimplementedError();

  @override
  // TODO: implement reorderItemLeft
  String get reorderItemLeft => throw UnimplementedError();

  @override
  // TODO: implement reorderItemRight
  String get reorderItemRight => throw UnimplementedError();

  @override
  // TODO: implement reorderItemToEnd
  String get reorderItemToEnd => throw UnimplementedError();

  @override
  // TODO: implement reorderItemToStart
  String get reorderItemToStart => throw UnimplementedError();

  @override
  // TODO: implement reorderItemUp
  String get reorderItemUp => throw UnimplementedError();

  @override
  // TODO: implement copyButtonLabel
  String get copyButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement cutButtonLabel
  String get cutButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement lookUpButtonLabel
  String get lookUpButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement noResultsFound
  String get noResultsFound => throw UnimplementedError();

  @override
  // TODO: implement pasteButtonLabel
  String get pasteButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement searchResultsFound
  String get searchResultsFound => throw UnimplementedError();

  @override
  // TODO: implement searchWebButtonLabel
  String get searchWebButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement selectAllButtonLabel
  String get selectAllButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement shareButtonLabel
  String get shareButtonLabel => throw UnimplementedError();
}

// Arabic translation
class $ar extends S {
  const $ar();

  @override
  // TODO: implement reorderItemDown
  String get reorderItemDown => throw UnimplementedError();

  @override
  // TODO: implement reorderItemLeft
  String get reorderItemLeft => throw UnimplementedError();

  @override
  // TODO: implement reorderItemRight
  String get reorderItemRight => throw UnimplementedError();

  @override
  // TODO: implement reorderItemToEnd
  String get reorderItemToEnd => throw UnimplementedError();

  @override
  // TODO: implement reorderItemToStart
  String get reorderItemToStart => throw UnimplementedError();

  @override
  // TODO: implement reorderItemUp
  String get reorderItemUp => throw UnimplementedError();
}

// English translation
class $en extends S {
  const $en();

  @override
  // TODO: implement reorderItemDown
  String get reorderItemDown => throw UnimplementedError();

  @override
  // TODO: implement reorderItemLeft
  String get reorderItemLeft => throw UnimplementedError();

  @override
  // TODO: implement reorderItemRight
  String get reorderItemRight => throw UnimplementedError();

  @override
  // TODO: implement reorderItemToEnd
  String get reorderItemToEnd => throw UnimplementedError();

  @override
  // TODO: implement reorderItemToStart
  String get reorderItemToStart => throw UnimplementedError();

  @override
  // TODO: implement reorderItemUp
  String get reorderItemUp => throw UnimplementedError();
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<S> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale("ar", ""),
      Locale("en", ""),
    ];
  }

  LocaleListResolutionCallback listResolution(
      {Locale? fallback, bool withCountry = true}) {
    return (List<Locale>? locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback!, supported, withCountry);
      }
    };
  }

  LocaleResolutionCallback resolution(
      {Locale? fallback, bool withCountry = true}) {
    return (Locale? locale, Iterable<Locale> supported) {
      return _resolve(locale!, fallback!, supported, withCountry);
    };
  }

  @override
  Future<S> load(Locale locale) {
    final String? lang = getLang(locale);
    if (lang != null) {
      switch (lang) {
        case "ar":
          S.current = const $ar();
          return SynchronousFuture<S>(S.current!);
        case "en":
          S.current = const $en();
          return SynchronousFuture<S>(S.current!);
        default:
        // NO-OP.
      }
    }
    S.current = const S();
    return SynchronousFuture<S>(S.current!);
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, true);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  ///
  /// Internal method to resolve a locale from a list of locales.
  ///
  Locale _resolve(Locale locale, Locale fallback, Iterable<Locale> supported,
      bool withCountry) {
    if (locale == null || !_isSupported(locale, withCountry)) {
      return fallback;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback;
      return fallbackLocale;
    }
  }

  ///
  /// Returns true if the specified locale is supported, false otherwise.
  ///
  bool _isSupported(Locale locale, bool withCountry) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        // Language must always match both locales.
        if (supportedLocale.languageCode != locale.languageCode) {
          continue;
        }

        // If country code matches, return this locale.
        if (supportedLocale.countryCode == locale.countryCode) {
          return true;
        }

        // If no country requirement is requested, check if this locale has no country.
        if (true != withCountry &&
            (supportedLocale.countryCode == null ||
                supportedLocale.countryCode!.isEmpty)) {
          return true;
        }
      }
    }
    return false;
  }
}

String? getLang(Locale l) => l == null
    ? null
    : l.countryCode != null && l.countryCode!.isEmpty
        ? l.languageCode
        : l.toString();
