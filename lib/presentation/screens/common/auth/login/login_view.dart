import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../configurations/data/api_services.dart';
import '../../../../../configurations/helpers_functions.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../../../configurations/resources/app_colors.dart';
import '../../../../../configurations/resources/assets_manager.dart';
import '../../../../custom_widgets/cust_svg_icons.dart';
import '../../../../custom_widgets/custom_button.dart';
import '../../../../custom_widgets/custom_text.dart';
import '../../../../custom_widgets/custom_text_field.dart';
import '../../../../custom_widgets/dialog/overlay_helper.dart';
import '../../../../custom_widgets/laguage_icon.dart';
import '../../../../custom_widgets/title_error_widget.dart';
import '../forget_password_email/forget_password_email_view.dart';
import '../singup/singup_view.dart';
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

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    await ApiService().getToken();
    userName = TextEditingController(text: loginViewModel.userName);
    password = TextEditingController(text: loginViewModel.password);
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
              SizedBox(
                height: 60,
              ),
              LanguageIcon(),
              SizedBox(height: 30,),
              Expanded(
                child: ListView(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageAssets.logo2,
                          width: widthOfScreen(context) * 0.3,
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),

                    SizedBox(height: 20,),

                    CustomText(
                      title: S.of(context)!.login,
                      fontWeight: FontWeight.bold,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! +
                          3,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    CustomText(
                      title: S.of(context)!.loginToYourAccounts,
                      color: Colors.black45,
                      size: Theme.of(context).textTheme.bodySmall!.fontSize! -
                          1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 25,
                    ),

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
                          '${S.of(context)!.enter} ${S.of(context)!.yourEmail}',
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
                      prefixIcon: CusSvgIcons(iconAssetString:
                      IconAssets.lock,
                      ),
                      suffixIcon: GestureDetector(
                          onTap: () => loginViewModel
                              .changeObscureText(!loginViewModel.obscureText),
                          child: CusSvgIcons(iconAssetString:
                          loginViewModel.obscureText
                                ? IconAssets.hidePassword
                                : IconAssets.viewPassword,
                            color: loginViewModel.password.isNotEmpty
                                ? Colors.black
                                : !loginViewModel.obscureText
                                    ? Colors.black
                                    : AppColors.current.grey,
                            size: 25,
                          ),
                      )
                    ),

                    const SizedBox(height: 15),

                    CustomButton(
                      text: S.of(context)!.login,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        try {
                          loginViewModel.onLoginClick(context);
                        } catch (e) {
                          debugPrint('************** error in login ${e.toString()}');
                          // OverlayHelper.showErrorToast(context, e.toString().replaceAll('Exception: ', ''));
                        }
                      },
                      loading: loginViewModel.isLoading,
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          title: S.of(context)!.youWantToHaveAccount,
                          size:
                              Theme.of(context).textTheme.bodySmall!.fontSize,
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(RegistrationScreen.routeName);
                            },
                            child: CustomText(
                              title: S.of(context)!.createAnAccount,
                              size: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .fontSize,
                              // fontWeight: FontWeight.bold,
                              color: AppColors.current.primary,
                            ),
                          ),
                        )
                      ],
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

// import 'package:flutter/material.dart';
//
// class LoginScreen extends StatelessWidget {
//
//   static const String routeName = "/LoginScreen";
//
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 16.0),
//                     child: Image.asset(
//                       'assets/icons/uk_flag.png',
//                       width: 32,
//                       height: 32,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 Image.asset(
//                   'assets/icons/logo.png',
//                   width: 72,
//                   height: 72,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'تسجيل الدخول',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'سجل دخولك للوصول إلى حسابك وبدء طلباتك بسهولة!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 32),
//                 _buildTextField(
//                   label: 'البريد الإلكتروني أو رقم الجوال *',
//                   hint: 'أدخل بريدك الإلكتروني أو رقم الجوال',
//                   icon: 'assets/icons/mail_icon.svg',
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTextField(
//                   label: 'كلمة المرور *',
//                   hint: 'أدخل كلمة المرور',
//                   icon: 'assets/icons/lock_icon.svg',
//                   obscure: true,
//                 ),
//                 const SizedBox(height: 8),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'هل نسيت كلمة المرور؟',
//                     style: TextStyle(color: Colors.orange[700]),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                     ),
//                     child: const Text(
//                       'سجل دخولك',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 // const SizedBox(height: 24),
//                 // const Text('أو التسجيل عن طريق'),
//                 // const SizedBox(height: 16),
//                 // Row(
//                 //   mainAxisAlignment: MainAxisAlignment.center,
//                 //   children: [
//                 //     _buildSocialIcon('assets/icons/apple_icon.png'),
//                 //     const SizedBox(width: 16),
//                 //     _buildSocialIcon('assets/icons/google_icon.png'),
//                 //     const SizedBox(width: 16),
//                 //     _buildSocialIcon('assets/icons/facebook_icon.png'),
//                 //   ],
//                 // ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [
//                     Text('ليس لديك حساب؟ '),
//                     Text(
//                       'إنشاء حساب',
//                       style: TextStyle(color: Colors.orange),
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required String label,
//     required String hint,
//     required String icon,
//     bool obscure = false,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           obscureText: obscure,
//           decoration: InputDecoration(
//             hintText: hint,
//             prefixIcon: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: SvgPicture.asset(
//                 icon,
//                 width: 20,
//                 height: 20,
//               ),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSocialIcon(String path) {
//     return CircleAvatar(
//       radius: 24,
//       backgroundColor: Colors.grey.shade100,
//       child: Image.asset(
//         path,
//         width: 24,
//         height: 24,
//       ),
//     );
//   }
// }
