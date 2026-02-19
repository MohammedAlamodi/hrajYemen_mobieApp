import 'package:flutter/material.dart';

import '../../../../../configurations/helpers_functions.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../../../configurations/resources/app_colors.dart';
import '../../../../../configurations/resources/assets_manager.dart';
import '../../../../custom_widgets/cust_svg_icons.dart';
import '../../../../custom_widgets/custom_button.dart';
import '../../../../custom_widgets/custom_text.dart';
import '../../../../custom_widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

import '../../../../custom_widgets/icon_with_bag.dart';
import '../../../../custom_widgets/laguage_icon.dart';
import '../login/login_view_model.dart';
import '../singup/singup_view.dart';
import 'forget_password_phone_view.dart';
import 'otp_for_email.dart';

class ForgetPasswordEmailView extends StatefulWidget {
  static const String routeName = "ForgetPasswordEmailView";

  ForgetPasswordEmailView({super.key});

  @override
  State<ForgetPasswordEmailView> createState() =>
      _ForgetPasswordEmailViewState();
}

class _ForgetPasswordEmailViewState extends State<ForgetPasswordEmailView> {
  bool obscureText = false;
  // late LoginViewModel loginViewModel;
  String? email;
  String? errorEmail;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // loginViewModel = Provider.of<LoginViewModel>(context);
    // email = TextEditingController(text: loginViewModel.userName);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CustomIconsWithBag(
                      color: AppColors.current.primary,
                      icon: Icons.arrow_back_ios_outlined,
                      iconColor: AppColors.current.primary,
                    ),
                  ),
                  LanguageIcon(),
                ],
              ),
              Expanded(
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        ImageAssets.logo,
                        width: widthOfScreen(context) * 0.18,
                        fit: BoxFit.fitWidth,
                      ),
                      CustomText(
                        title: S.of(context)!.forgetPassword,
                        fontWeight: FontWeight.bold,
                        size:
                            Theme.of(context).textTheme.bodyLarge!.fontSize! + 2,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      CustomText(
                        title: S.of(context)!.enterEmail,
                        color: Colors.black54,
                        size:
                            Theme.of(context).textTheme.bodySmall!.fontSize! - 1,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      CustomTextField(
                        textAlign: TextAlign.start,
                        title: '${S.of(context)!.email_} *',
                        // controller: email,
                        onChange: (value) {
                          if(value != ''){
                            setState(() {
                              errorEmail = null;
                            });
                          }
                          email = value;
                        },
                        type: TextInputType.emailAddress,
                        prefixIcon: CusSvgIcons(iconAssetString:
                          IconAssets.email,
                          ),
                        hint: '${S.of(context)!.enter} ${S.of(context)!.email_}',
                        errorText: errorEmail,
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: S.of(context)!.restPassword,
                        onTap: () {
                          // email@email.com
                          FocusScope.of(context).requestFocus(FocusNode());
                            if(email == null || email == ''){
                              setState(() {
                                errorEmail = S.of(context)!.requiredFiled;
                              });
                            }else{
                              if (!email!.contains('@') || !email!.contains('.')) {
                                setState(() {
                                  errorEmail = S.of(context)!.errorInInout;
                                });
                              }else{
                                Navigator.of(context).pushNamed(OtpForEmailScreen.routeName);
                              }
                            }
                        },
                        // loading: loginViewModel.isLoading,
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          Divider(),
                          Center(
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: CustomText(
                                title: S.of(context)!.orRestBy,
                                size: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .fontSize,
                                color: Colors.black45,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        text: S.of(context)!.orRestByPhoneNum,
                        btnColor: Colors.white70,
                        btnTextColor: AppColors.current.primary,
                        borderColor: Colors.white,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.of(context).pushNamed(ForgetPasswordPhoneView.routeName);
                        },
                        // loading: loginViewModel.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
