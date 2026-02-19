import 'package:flutter/material.dart';
import '../../../../../configurations/localization/i18n.dart';
import '../../../../custom_widgets/dialog/error_dialog.dart';
import '../../../../custom_widgets/dialog/overlay_helper.dart';
import '../login/login_view.dart';
import 'singup_view_rep.dart';
import 'package:dio/dio.dart';

class RegisterModel {
  String username = '';
  String email = '';
  String password = '';
  UserRolesModel? role;
  String name = '';
  String foreignName = '';
  String contactInfo = '';
  String address = '';
  String phone = '';
  String logo = '';

  RegisterModel();
}

class RegistrationViewModel extends ChangeNotifier {
  final RegisterModel _model = RegisterModel();
  final RegistrationViewRepository _repo = RegistrationViewRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? roleError;
  String? nameError;
  String? addressError;
  String? phoneError;
  String? phoneCuntry = '+967';
  List<UserRolesModel>? userRolesModel;

  String get username => _model.username;

  String get email => _model.email;

  String get password => _model.password;

  String get confirmPassword => _model.password; // كلمة مرور للتأكيد

  UserRolesModel?  get role => _model.role;

  String get name => _model.name;

  String get foreignName => _model.foreignName;

  String get contactInfo => _model.contactInfo;

  String get address => _model.address;

  String get phone => _model.phone;

  String get logo => _model.logo;
  String _confirmPassword = '';

  void setUsername(String value) {
    _model.username = value;
    usernameError = null;
    notifyListeners();
  }

  void setEmail(String value) {
    _model.email = value;
    emailError = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _model.password = value;
    passwordError = null;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    confirmPasswordError = null;
    notifyListeners();
  }

  void setRole({
    context,
    int? indexOfSelectedItem,
  }) {
    _model.role = userRolesModel?[indexOfSelectedItem ?? 0];
    Navigator.of(context).pop();
    roleError = null;
    notifyListeners();
  }

  void setName(String value) {
    _model.name = value;
    nameError = null;
    notifyListeners();
  }

  void setFogName(String value) {
    _model.foreignName = value;
    notifyListeners();
  }

  void setContactInfoName(String value) {
    _model.contactInfo = value;
    notifyListeners();
  }

  void setAddress(String value) {
    _model.address = value;
    addressError = null;
    notifyListeners();
  }

  void setPhone(String value) {
    _model.phone = value;
    phoneError = null;
    notifyListeners();
  }

  void setCunteryOfPhone(String value) {
    phoneCuntry = value;
    notifyListeners();
  }

  bool validate(context) {
    bool isValid = true;

    if (_model.username.isEmpty) {
      // usernameError = 'Username is required';
      usernameError = S.of(context)!.requiredFiled;
      isValid = false;
    }

    if (_model.email.isEmpty) {
      // emailError = 'Please enter a valid email address';
      emailError = S.of(context)!.requiredFiled;
      isValid = false;
    }

    if (!_model.email.contains('@')) {
      // emailError = 'Please enter a valid email address';
      emailError = S.of(context)!.emailValid;
      isValid = false;
    }

    if (_model.password.isEmpty) {
      // passwordError = 'Password is required';
      passwordError = S.of(context)!.requiredFiled;
      isValid = false;
    }

    if (_model.password.length < 6) {
      // passwordError = 'Password is required';
      passwordError = S.of(context)!.password;
      isValid = false;
    }

    if (_confirmPassword.isEmpty || _confirmPassword != _model.password) {
      // confirmPasswordError = 'Passwords do not mat@@@@##@@@2ssdch';
      confirmPasswordError = S.of(context)!.confirmPasswordError;
      isValid = false;
    }

    if (_model.role == null) {
      // roleError = 'Role is required';
      roleError = S.of(context)!.requiredFiled;
      isValid = false;
    }

    if (_model.name.isEmpty) {
      // nameError = 'Name is required';
      nameError = S.of(context)!.requiredFiled;
      isValid = false;
    }

    if (_model.address.isEmpty) {
      // addressError = 'Address is required';
      addressError = S.of(context)!.requiredFiled;
      isValid = false;
    }

    if (_model.phone.isEmpty || _model.phone.length < 9) {
      // phoneError = 'Please enter a valid phone number';
      phoneError = S.of(context)!.requiredFiled;
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  onRegistrationClick(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    bool val = validate(context);
    if (val) {
      try {
        _model.phone = '${phoneCuntry}${_model.phone}';
        var user =
            await _repo.registerUser(context, model: _model);

        debugPrint('~~~~~~~~ ${user.toString().contains('successfully')}');

        if (user["message"].toString().contains('successfully')) {
          _isLoading = false;
          notifyListeners();

          await showNoteDialog(
              context: context,
              message: S.of(context)!.processDone,
              description: S.of(context)!.registerDone,
              confirmButtonTitle: S.of(context)!.goToLogin,
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginScreen.routeName,
                  (Route<dynamic> route) => false,
                );
              });
        }
      } on DioException catch (e) {
        _isLoading = false;
        notifyListeners();
        if (e.response != null) {
          String errorMessage =
              e.response?.data['message'] ?? 'An error occurred';
          debugPrint('error message1 $errorMessage');
          await showErrorDialog(
              context: context,
              message: S.of(context)!.errorHap,
              description: errorMessage);
        } else {
          String errorMessage = 'Network error: ${e.message}';
          debugPrint('error in login $errorMessage');
        }
      } catch (e) {
        debugPrint('***********error in login ${e.toString()}');

        // OverlayHelper.showErrorToast(context, S.of(context)!.anErrorOccurred);
      }
      _isLoading = false;
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }
}

class UserRolesModel {
  final String name;

  UserRolesModel(this.name);

}
