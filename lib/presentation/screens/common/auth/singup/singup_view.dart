import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../configurations/helpers_functions.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../../../configurations/resources/app_colors.dart';
import '../../../../../configurations/resources/assets_manager.dart';
import '../../../../custom_widgets/cus_phone_field.dart';
import '../../../../custom_widgets/cust_svg_icons.dart';
import '../../../../custom_widgets/custom_bottom_sheet/custom_bottom_sheet_list.dart';
import '../../../../custom_widgets/custom_button.dart';
import '../../../../custom_widgets/custom_text.dart';
import '../../../../custom_widgets/custom_text_field.dart';
import '../../../../custom_widgets/icon_with_bag.dart';
import '../../../../custom_widgets/laguage_icon.dart';
import '../../common_view_model.dart';
import 'phoneVirev.dart';
import 'singup_view_model.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = "/RegistrationScreen";

  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late RegistrationViewModel registrationVM;
  late CommonViewModel commonVM;

  // bool validateError = false;
  late List<String> roles ;
  late String selectedRole;

  TextEditingController userName = TextEditingController();
  String? errorInUserName;

  TextEditingController email = TextEditingController();
  String? errorInEmail;

  TextEditingController phoneNumber = TextEditingController();
  String? phoneCuntry = '+967';
  String? errorInPhone;

  TextEditingController password = TextEditingController();
  bool obscureText = true;
  String? errorInPassword;

  TextEditingController password2 = TextEditingController();
  bool obscureText2 = true;
  String? errorInPassword2;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      registrationVM =
          Provider.of<RegistrationViewModel>(context, listen: false);
      commonVM = Provider.of<CommonViewModel>(context, listen: false);


      setState(() {
        roles = ['مشتـري', 'بائـع', 'موصل'];

        selectedRole = roles[0];
      });


      // await commonVM.getUseRoles(context);
      // registrationVM.userRolesModel = commonVM.userRoles;
    });
  }

  @override
  Widget build(BuildContext context) {
    registrationVM = Provider.of<RegistrationViewModel>(context);
    commonVM = Provider.of<CommonViewModel>(context);
    // roles = ['مشتـري', 'بائـع', 'موصل'];
    // registrationVM.userRolesModel = commonVM.userRoles;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
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
              Image.asset(
                ImageAssets.logo,
                width: widthOfScreen(context) * 0.18,
                fit: BoxFit.fitWidth,
              ),
              CustomText(
                title: S.of(context)!.createAnAccount,
                fontWeight: FontWeight.bold,
                size: Theme.of(context).textTheme.bodyLarge!.fontSize! + 3,
              ),
              SizedBox(
                height: 15,
              ),
              CustomText(
                title: S.of(context)!.suingToYourAccounts,
                color: Colors.black45,
                textAlign: TextAlign.center,
                size: Theme.of(context).textTheme.bodySmall!.fontSize! -
                    1,
              ),
              SizedBox(
                  height: isTablet(context)? 120 : 90,
                  child: RoleSelectionScreen(
                    roles: roles,
                    selectedRole: selectedRole,
                    onTap: (v){
                      debugPrint('======== v $v');
                      setState(() {
                        selectedRole = v;
                      });
                    },
                  )
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(0.0),
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      textAlign: TextAlign.start,
                      controller: userName,
                      title: '${S.of(context)!.userName} *',
                      validator: (value) => null,
                      type: TextInputType.text,
                      onChange: (v){
                        setState(() {
                          errorInUserName = null;
                        });
                      },
                      prefixIcon: CusSvgIcons(iconAssetString: IconAssets.person,),
                      hint: '${S.of(context)!.enter} ${S.of(context)!.yourName}',
                      errorText: errorInUserName,
                    ),
                
                    CustomTextField(
                      textAlign: TextAlign.start,
                      title: '${S.of(context)!.email_} *',
                      controller: email,
                      validator: (value) => null,
                      type: TextInputType.text,
                      onChange: (v){
                        setState(() {
                          errorInEmail = null;
                        });
                      },
                      prefixIcon: CusSvgIcons(iconAssetString: IconAssets.email,),
                      hint: '${S.of(context)!.enter} ${S.of(context)!.yourEmail}',
                      errorText: errorInEmail,
                    ),
                
                    CusPhoneField(
                      errorPhone: errorInPhone,
                      phoneCuntry: phoneCuntry,
                      controller: phoneNumber,
                      onDropdownChanged: (v){
                        setState(() {
                          phoneCuntry = v;
                          debugPrint('******** phoneCuntry = $v');
                        });
                      },
                      onTextChanged: (v){
                        setState(() {
                          errorInPhone = null;
                        });
                      },
                    ),
                
                    CustomTextField(
                      textAlign: TextAlign.start,
                      title: '${S.of(context)!.email_} *',
                      controller: email,
                      validator: (value) => null,
                      type: TextInputType.text,
                      onChange: (v){
                        setState(() {
                          errorInEmail = null;
                        });
                      },
                      prefixIcon: CusSvgIcons(iconAssetString: IconAssets.email,),
                      hint: '${S.of(context)!.enter} ${S.of(context)!.yourEmail}',
                      errorText: errorInEmail,
                    ),

                    _buildPasswordField(context),

                    _buildConfirmPasswordField(context),

                    CustomButton(
                      text: S.of(context)!.sinUpNow2,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        try {
                          registrationVM.onRegistrationClick(context);
                        } catch (e) {
                          debugPrint(e.toString());
                          // OverlayHelper.showErrorDialog(
                          //     context, e.toString());
                        }
                      },
                      loading: registrationVM.isLoading,
                    ),
                    const SizedBox(height: 10),
                
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          title: S.of(context)!.youHaveAccount,
                          size:
                              Theme.of(context).textTheme.bodySmall!.fontSize,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: CustomText(
                              title: S.of(context)!.login,
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

  Widget _buildConfirmPasswordField(context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomTextField(
        textAlign: TextAlign.start,
        controller: password2,
        title: '${S.of(context)!.confPassword} *',
        validator: (value) => null,
        type: TextInputType.text,
        obscureText: obscureText2,
        hint: S.of(context)!.confPassword,
        errorText: errorInPassword2,
        prefixIcon: CusSvgIcons(iconAssetString:
        IconAssets.lock,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              obscureText2 = !obscureText2;
            });
          },
          child: CusSvgIcons(iconAssetString:
          obscureText2
              ? IconAssets.hidePassword
              : IconAssets.viewPassword,
            color: password2.text.isNotEmpty
                ? Colors.black
                : !obscureText2
                ? Colors.black
                : AppColors.current.grey,
            size: 25,
          ),
        ),
        onChange: (v){
          setState(() {
            errorInPassword2 = null;
          });
        },
      ),
    );
  }

  Widget _buildPasswordField(context) {
    return CustomTextField(
      textAlign: TextAlign.start,
      controller: password,
      title: '${S.of(context)!.password} *',
      validator: (value) => null,
      type: TextInputType.text,
      obscureText: obscureText,
      hint: '${S.of(context)!.enter} ${S.of(context)!.password}',
      errorText: errorInPassword,
      suffixText: _getPasswordStrength(context, password.text),
      suffixTextColor: _getPasswordStrengthColor(password.text),
      prefixIcon: CusSvgIcons(iconAssetString:
      IconAssets.lock,
      ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
          child: CusSvgIcons(iconAssetString:
          obscureText
              ? IconAssets.hidePassword
              : IconAssets.viewPassword,
            color: password.text.isNotEmpty
                ? Colors.black
                : !obscureText
                ? Colors.black
                : AppColors.current.grey,
            size: 25,
          ),
        ),
        onChange: (v){
        setState(() {
          errorInPassword = null;
        });
      },
    );
  }

  String _getPasswordStrength(context, String password) {
    if (password.length < 6) return S.of(context)!.weak;
    if (password.length < 10) return S.of(context)!.medium;
    return S.of(context)!.strong;
  }

  Color _getPasswordStrengthColor(String password) {
    if (password.length < 6) return Colors.redAccent;
    if (password.length < 10) return Colors.amber;
    return Colors.greenAccent;
  }

  Widget _buildPhoneField(RegistrationViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: S.of(context)!.phone,
                  errorText: viewModel.phoneError,
                  type: TextInputType.phone,
                  onChange: viewModel.setPhone,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.black,
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: DropdownButton<String>(
                      value: viewModel.phoneCuntry,
                      items: ['+967', '+966', '+1', '+971', '+44']
                          .map((code) =>
                              DropdownMenuItem(value: code, child: Text(code)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          viewModel.setCunteryOfPhone(v);
                        }
                      }),
                ),
              ),
            ],
          ),
          // GestureDetector(
          //     onTap: () {
          //       Navigator.pushNamed(context, OtpPage.routeName);
          //     },
          //     child: CustomText(
          //       color: Colors.blue,
          //       title: 'vervit phone',
          //     ))
        ],
      ),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  final List<String> roles;
  final String selectedRole;
  final Function(String) onTap;

  const RoleSelectionScreen(
      {super.key, required this.roles, required this.selectedRole, required this.onTap});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // final List<String> roles = ['مشتـري', 'بائـع', 'موصل'];
  //
  // String selectedRole = 'مشتـري';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.roles.map((role) {
          bool isSelected = role == widget.selectedRole;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: isTablet(context) ? 150 : widthOfScreen(context) * 0.28,
              child: GestureDetector(
                onTap: (){
                  widget.onTap(role);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.current.primary
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: CustomText(
                      title: role,
                      color: isSelected
                          ? AppColors.current.primary
                          : Colors.black38,
                      size: Theme.of(context).textTheme.bodySmall!.fontSize,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
