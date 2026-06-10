import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../configurations/resources/app_colors.dart';
import '../../../../../configurations/resources/assets_manager.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../custom_widgets/cust_svg_icons.dart';
import '../../../custom_widgets/custom_button.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../../custom_widgets/custom_text_field.dart';
import '../../../custom_widgets/laguage_icon.dart';
import '../../common/auth/login/login_view_model.dart';


class WebAdminLoginScreen extends StatefulWidget {
  const WebAdminLoginScreen({super.key});

  @override
  State<WebAdminLoginScreen> createState() => _WebAdminLoginScreenState();
}

class _WebAdminLoginScreenState extends State<WebAdminLoginScreen> {
  late LoginViewModel loginViewModel;
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    userName = TextEditingController(text: loginViewModel.userName);
    password = TextEditingController(text: loginViewModel.password);
  }

  @override
  Widget build(BuildContext context) {
    loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // لون خلفية هادئ للويب
      body: Stack(
        children: [
          // const Positioned(
          //   top: 20,
          //   right: 20,
          //   child: LanguageIcon(),
          // ),
          Center(
            child: Container(
              width: 450, // عرض ثابت للبطاقة في الويب
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ListView(
                children: [
                  Center(
                    child: Image.asset(
                      ImageAssets.logo2,
                      width: 250,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: CustomText(
                      title: 'لوحة تحكم الإدارة',
                      fontWeight: FontWeight.bold,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! + 3,
                      color: AppColors.current.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: CustomText(
                      title: 'مرحباً بك، يرجى تسجيل الدخول للمتابعة',
                      color: Colors.black45,
                      size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,
                    ),
                  ),
                  const SizedBox(height: 40),

                  CustomTextField(
                    textAlign: TextAlign.start,
                    controller: userName,
                    title: '${S.of(context)!.userName} *',
                    validator: (value) => null,
                    onChange: (value) => loginViewModel.emailOnChanged(value.trim()),
                    type: TextInputType.text,
                    prefixIcon: CusSvgIcons(iconAssetString: IconAssets.email),
                    hint: '${S.of(context)!.enter} ${S.of(context)!.yourEmail}',
                    errorText: loginViewModel.errorEmail,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    textAlign: TextAlign.start,
                    controller: password,
                    title: '${S.of(context)!.password} *',
                    onChange: (value) => loginViewModel.passwordOnChanged(value.trim()),
                    validator: (value) => null,
                    type: TextInputType.text,
                    obscureText: loginViewModel.obscureText,
                    hint: '${S.of(context)!.enter} ${S.of(context)!.password}',
                    errorText: loginViewModel.errorPass,
                    prefixIcon: CusSvgIcons(iconAssetString: IconAssets.lock),
                    suffixIcon: GestureDetector(
                      onTap: () => loginViewModel.changeObscureText(!loginViewModel.obscureText),
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
                  const SizedBox(height: 30),

                  CustomButton(
                    text: S.of(context)!.login,
                    btnTextSize: Theme.of(context).textTheme.bodySmall!.fontSize! - 5,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      try {
                        loginViewModel.onLoginClick(context);
                        // بعد تسجيل الدخول الناجح في الويب، وجهه للوحة التحكم
                        // Navigator.pushReplacementNamed(context, AdminMainLayout.routeName);
                      } catch (e) {
                        debugPrint('Error: $e');
                      }
                    },
                    loading: loginViewModel.isLoading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}