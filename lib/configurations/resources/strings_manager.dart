class AppStrings {
  static String staticToken = '';
  static const String noInternetError = "no_internet_error";

  static const loginTokenKey = "loginToken";
  static const refreshToken = "refreshToken";
  static const userIdKey = "id";
  static const userEmailKey = "email";
  static const userNameKey = "name";
  static const userTypeKey = "userTypeKey";
  static const cookie = "cookie";
  // static const loginToken = "loginToken";

  static const languageKey = "languageKey";

  static String get baseUrl => 'baseUrl';

}

enum PopType {
  truePop,
  falsePop,
  infoPop,
  favouritePop,
  popDeleteIcon,
  popCallIcon
}
