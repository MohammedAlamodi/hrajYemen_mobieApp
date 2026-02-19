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
import 'package:flutter/services.dart';

import '../../../../custom_widgets/icon_with_bag.dart';
import '../../../../custom_widgets/laguage_icon.dart';
import '../login/login_view.dart';
import '../login/login_view_model.dart';
import '../singup/singup_view.dart';

class OtpForEmailScreen extends StatefulWidget {
  static const String routeName = "OtpForEmailScreen";

  const OtpForEmailScreen({super.key});

  @override
  State<OtpForEmailScreen> createState() =>
      _OtpForEmailScreenState();
}

class _OtpForEmailScreenState extends State<OtpForEmailScreen> {
  bool obscureText = false;
  late LoginViewModel loginViewModel;


  @override
  Widget build(BuildContext context) {
    loginViewModel = Provider.of<LoginViewModel>(context);

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

            // SizedBox(height: heightOfScreen(context) * 0.16,),
            Expanded(
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CusSvgIcons(iconAssetString:
                    IconAssets.otpSvg,
                      size: widthOfScreen(context) * 0.35,
                    ),
                    CustomText(
                      title: S.of(context)!.sureOTP,
                      fontWeight: FontWeight.bold,
                      size:
                      Theme.of(context).textTheme.bodyLarge!.fontSize! + 2,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    CustomText(
                      title: S.of(context)!.enterOTP,
                      color: Colors.black54,
                      textAlign: TextAlign.center,
                      size: Theme.of(context).textTheme.bodySmall!.fontSize!,
                    ),
                    SizedBox(
                      height: 25,
                    ),

                  CustomTextField(
                    onChange: (v){

                    },

                  ),

                  //   OtpBoxes(
                  //   onCompleted: (code) {
                  //     print('OTP Completed: $code');
                  //   },
                  // ),

                    const SizedBox(height: 10),

                    //لم يصلك رمز التحقق على البريد ؟
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          title: S.of(context)!.thereIsNoOTP,
                          color: Colors.black54,
                          textAlign: TextAlign.center,
                          size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,

                        ),
                        GestureDetector(
                          onTap: (){},
                          child: CustomText(
                            title: S.of(context)!.resentOTP,
                            color: AppColors.current.primary,
                            textAlign: TextAlign.center,
                            size: Theme.of(context).textTheme.bodySmall!.fontSize! -1,

                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    //تحقق
                    CustomButton(
                      text: S.of(context)!.conf,
                      onTap: () {
                        // FocusScope.of(context).unfocus();
                      },
                      loading: loginViewModel.isLoading,
                    ),

                    const SizedBox(height: 10),

                    // هل تذكرت كلمة مرورك ؟
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          title: S.of(context)!.doYouRememberPassword,
                          color: Colors.black54,
                          textAlign: TextAlign.center,
                          size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,

                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).popAndPushNamed(LoginScreen.routeName);
                          },
                          child: CustomText(
                            title: S.of(context)!.login,
                            color: AppColors.current.primary,
                            textAlign: TextAlign.center,
                            size: Theme.of(context).textTheme.bodySmall!.fontSize! - 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
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
                    const SizedBox(height: 10),
                    CustomButton(
                      text: S.of(context)!.orRestByPhoneNum,
                      btnColor: Colors.white70,
                      btnTextColor: AppColors.current.primary,
                      borderColor: Colors.white,
                      onTap: () {
                        // FocusScope.of(context).unfocus();
                      },
                      loading: loginViewModel.isLoading,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            // SizedBox(height: heightOfScreen(context) * 0.16,),

          ],
        ),
      ),
    );
  }
}

class OtpBoxes extends StatefulWidget {
  final int length;
  final void Function(String)? onCompleted;

  const OtpBoxes({
    super.key,
    this.length = 6,
    this.onCompleted,
  });

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _controllers[index].text = value[0];
      if (index < widget.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    }
    _checkCompletion();
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
    }
  }

  void _checkCompletion() {
    final otp = _controllers.map((e) => e.text).join();
    if (otp.length == widget.length && !_controllers.any((c) => c.text.isEmpty)) {
      widget.onCompleted?.call(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.length, (index) {
          return SizedBox(
            width: 50,
            height: 60,
            child: Focus(
              focusNode: _focusNodes[index],
              onKey: (_, RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  _onBackspace(index);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(fontSize: 20),
                onChanged: (val) => _onChanged(val, index),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: _controllers[index].text.isEmpty
                      ? Colors.white
                      : Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
