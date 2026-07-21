import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_view_model.dart';
import 'package:ye_hraj/presentation/screens/common/auth/forget_password_email/forgot_password_screen.dart';
import '../../../../../configurations/data/api_services.dart';
import '../../../../../configurations/helpers_functions.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../../../configurations/resources/app_colors.dart';
import '../../../../../configurations/resources/assets_manager.dart';
import '../../../../custom_widgets/cust_svg_icons.dart';
import '../../../../custom_widgets/custom_button.dart';
import '../../../../custom_widgets/custom_text.dart';
import '../../../../custom_widgets/custom_text_field.dart';
import '../../../../custom_widgets/laguage_icon.dart';
import '../register/register_view.dart';
import 'custom_widgets/guest_entry_button.dart';
import 'login_view_model.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/LoginView";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginViewModel loginViewModel;
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController databaseController = TextEditingController();

  // String? _selectedUrl;
  // String? _selectedDatabase;

  /// مؤقّت دوري يتحقق من تحميل المدن، ويطلبها إن لم تكن محمّلة.
  Timer? _citiesCheckTimer;

  /// الفترة بين كل محاولة تحقّق.
  static const Duration _citiesCheckInterval = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _init();
    _startCitiesWatcher();
  }

  Future<void> _init() async {
    loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    await ApiService().getToken();
    userName = TextEditingController(text: loginViewModel.userName);
    password = TextEditingController(text: loginViewModel.password);
  }

  /// يبدأ المراقبة: محاولة فورية ثم تكرار كل [_citiesCheckInterval].
  /// عند توفّر المدن يتوقف المؤقّت لتفادي استهلاك الموارد.
  void _startCitiesWatcher() {
    // محاولة فورية بعد اكتمال أول إطار حتى يكون الـ context جاهزاً.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndLoadCities());

    _citiesCheckTimer =
        Timer.periodic(_citiesCheckInterval, (_) => _checkAndLoadCities());
  }

  Future<void> _checkAndLoadCities() async {
    if (!mounted) return;
    final commonVM = Provider.of<CommonViewModel>(context, listen: false);

    // إذا كانت المدن محمّلة مسبقاً، أوقف المراقبة ولا تفعل شيئاً.
    if (commonVM.hasCities) {
      _citiesCheckTimer?.cancel();
      _citiesCheckTimer = null;
      return;
    }

    // غير محمّلة: أرسل طلباً (الحارس داخل الـ VM يمنع الطلبات المتزامنة).
    final loaded = await commonVM.ensureCitiesLoaded(context);
    if (loaded && mounted) {
      _citiesCheckTimer?.cancel();
      _citiesCheckTimer = null;
    }
  }

  @override
  void dispose() {
    _citiesCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 40),
              // LanguageIcon(),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageAssets.logo2,
                          width: widthOfScreen(context) * 0.5,
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    CustomText(
                      title: S.of(context)!.login,
                      fontWeight: FontWeight.bold,
                      size:
                          Theme.of(context).textTheme.bodyLarge!.fontSize! + 3,
                    ),
                    SizedBox(height: 15),
                    CustomText(
                      title: S.of(context)!.loginToYourAccounts,
                      color: Colors.black45,
                      size:
                          Theme.of(context).textTheme.bodySmall!.fontSize! - 1,
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 25),

                    CustomTextField(
                      textAlign: TextAlign.start,
                      controller: userName,
                      title: '${S.of(context)!.userName} *',
                      validator: (value) => null,
                      onChange: (value) =>
                          loginViewModel.emailOnChanged(value.trim()),
                      type: TextInputType.text,
                      prefixIcon: CusSvgIcons(
                        iconAssetString: IconAssets.email,
                      ),
                      hint:
                          '${S.of(context)!.enter} ${S.of(context)!.userName} أو ${S.of(context)!.phone}',
                      errorText: loginViewModel.errorEmail,
                    ),

                    const SizedBox(height: 15),

                    CustomTextField(
                      textAlign: TextAlign.start,
                      controller: password,
                      title: '${S.of(context)!.password} *',
                      onChange: (value) =>
                          loginViewModel.passwordOnChanged(value.trim()),
                      validator: (value) => null,
                      type: TextInputType.text,
                      obscureText: loginViewModel.obscureText,
                      hint:
                          '${S.of(context)!.enter} ${S.of(context)!.password}',
                      errorText: loginViewModel.errorPass,
                      prefixIcon: CusSvgIcons(iconAssetString: IconAssets.lock),
                      suffixIcon: GestureDetector(
                        onTap: () => loginViewModel.changeObscureText(
                          !loginViewModel.obscureText,
                        ),
                        child: CusSvgIcons(
                          iconAssetString: loginViewModel.obscureText
                              ? IconAssets.hidePassword
                              : IconAssets.viewPassword,
                          color: loginViewModel.password.isNotEmpty
                              ? Colors.black
                              : !loginViewModel.obscureText
                              ? Colors.black
                              : AppColors.current.grey,
                          size: 25,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    CustomButton(
                      text: S.of(context)!.login,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        try {
                          loginViewModel.onLoginClick(context);
                        } catch (e) {
                          debugPrint(
                            '************** error in login ${e.toString()}',
                          );
                        }
                      },
                      loading: loginViewModel.isLoading,
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                              title: S.of(context)!.youWantToHaveAccount,
                              size: Theme.of(
                                context,
                              ).textTheme.bodySmall!.fontSize,
                            ),

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(RegisterScreen.routeName);
                                },
                                child: CustomText(
                                  title: S.of(context)!.createAnAccount,
                                  size: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.fontSize,
                                  // fontWeight: FontWeight.bold,
                                  color: AppColors.current.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: CustomText(
                              title: S.of(context)!.forgetPassword,
                              size: Theme.of(
                                context,
                              ).textTheme.bodySmall!.fontSize,
                              // fontWeight: FontWeight.bold,
                              color: AppColors.current.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [GuestEntryButton()],
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
