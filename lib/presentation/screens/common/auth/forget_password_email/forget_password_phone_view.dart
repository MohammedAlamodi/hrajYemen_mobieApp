import 'package:flutter/material.dart';

import '../../../../../configurations/helpers_functions.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../../../configurations/resources/app_colors.dart';
import '../../../../../configurations/resources/assets_manager.dart';
import '../../../../custom_widgets/cus_phone_field.dart';
import '../../../../custom_widgets/custom_button.dart';
import '../../../../custom_widgets/custom_text.dart';
import '../../../../custom_widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

import '../../../../custom_widgets/icon_with_bag.dart';
import '../../../../custom_widgets/laguage_icon.dart';
import '../login/login_view_model.dart';
import '../singup/singup_view.dart';

class ForgetPasswordPhoneView extends StatefulWidget {
  static const String routeName = "ForgetPasswordPhoneView";

  const ForgetPasswordPhoneView({super.key});

  @override
  State<ForgetPasswordPhoneView> createState() =>
      _ForgetPasswordPhoneViewState();
}

class _ForgetPasswordPhoneViewState extends State<ForgetPasswordPhoneView> {
  bool obscureText = false;

  // late LoginViewModel loginViewModel;
  String? phoneNumber;
  String? phoneCuntry = '+967';
  String? errorPhone;

  @override
  Widget build(BuildContext context) {
    // loginViewModel = Provider.of<LoginViewModel>(context);
    // email = TextEditingController(text: loginViewModel.userName);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
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
                      title: S.of(context)!.enterPhone,
                      color: Colors.black54,
                      size:
                          Theme.of(context).textTheme.bodySmall!.fontSize! - 1,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        CustomText(
                          title: '${S.of(context)!.phone} *',
                          textAlign: TextAlign.start,
                          size:
                              Theme.of(context).textTheme.bodySmall!.fontSize!,
                        ),
                      ],
                    ),
                    CusPhoneField(
                      errorPhone: errorPhone,
                      phoneCuntry: phoneCuntry,
                      // controller: p,
                      onDropdownChanged: (v){
                        setState(() {
                          phoneCuntry = v;
                          debugPrint('******** phoneCuntry = $v');
                        });
                      },
                      onTextChanged: (v){
                        setState(() {
                          errorPhone = null;
                          phoneNumber = v;
                        });
                      },
                    ),

                    const SizedBox(height: 10),
                    CustomButton(
                      text: S.of(context)!.restPassword,
                      onTap: () {
                        // email@email.com
                        // FocusScope.of(context).requestFocus(FocusNode());
                        // if(email == null || email == ''){
                        //   setState(() {
                        //     errorEmail = S.of(context)!.requiredFiled;
                        //   });
                        // }
                        // else{
                        //   if (!email!.contains('@') || !email!.contains('.')) {
                        //     setState(() {
                        //       errorEmail = S.of(context)!.errorInInout;
                        //     });
                        //   }else{
                        //     Navigator.of(context).pushNamed(OtpForEmailScreen.routeName);
                        //   }
                        // }
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
                      text: S.of(context)!.orRestByEmailNum,
                      btnColor: Colors.white70,
                      btnTextColor: AppColors.current.primary,
                      borderColor: Colors.white,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pop(context);
                        // Navigator.of(context).pushReplacementNamed(ForgetPasswordEmailView.routeName);
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
    );
  }
}

// class CusPhoneField extends StatelessWidget {
//   String? errorPhone;
//   String? phoneCuntry;
//   final Function(String?) onDropdownChanged;
//   final Function(String?) onTextChanged;
//
//   CusPhoneField(
//       {super.key,
//       this.errorPhone,
//         this.phoneCuntry,
//       required this.onDropdownChanged,
//       required this.onTextChanged});
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomTextField(
//       hint: '${S.of(context)!.enter} ${S.of(context)!.phone}',
//       errorText: errorPhone,
//       type: TextInputType.phone,
//       onChange: (value) {
//         onTextChanged(value);
//       },
//       // onChange: (v) {
//       //   FocusScope.of(context).requestFocus(FocusNode());
//       //   if (phoneNumber == null || phoneNumber == '') {
//       //     setState(() {
//       //       errorPhone = S.of(context)!.requiredFiled;
//       //     });
//       //   } else {
//       //     Navigator.of(context)
//       //         .pushNamed(OtpForEmailScreen.routeName);
//       //   }
//       // },
//       suffixIcon: DropdownButton<String>(
//         value: phoneCuntry,
//         icon: const SizedBox.shrink(), // إخفاء السهم
//         underline: const SizedBox.shrink(), // إخفاء الخط السفلي الأصلي
//         items: ['+967', '+966', '+1', '+971', '+44']
//             .map((code) => DropdownMenuItem(
//           value: code,
//           child: Row(
//             children: [
//               VerticalDivider(
//                 width: 1,
//                 endIndent: 10,
//                 indent: 10,
//                 color: Colors.black45,
//               ),
//               // Container(
//               //   height: 25,
//               //   width: 1, // طول الخط الجانبي
//               //   color: Colors.black26,
//               // ),
//               const SizedBox(width: 10),
//
//               Center(
//                 child: CustomText(
//                   title: code,
//                   size: Theme.of(context).textTheme.bodySmall!.fontSize,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(width: 14),
//
//             ],
//           ),
//         ))
//             .toList(),
//         onChanged: (v) {
//           onDropdownChanged(v);
//         },
//       ),
//       prefixIcon: CusSvgIcons(
//         iconAssetString: IconAssets.mobile,
//       ),
//     );
//   }
// }
