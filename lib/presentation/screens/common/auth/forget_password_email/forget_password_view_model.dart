

import 'package:flutter/foundation.dart';

class ForgetPasswordViewModel extends ChangeNotifier{

  var email = '';

  onLoginClick() {
    // validate name
    if (!email.isNotEmpty) {
      // OverlayHelper.showErrorToast(AppText.invalidUserName);
      return;
    }
    // callLoginApi();
    // Get.toNamed(Routes.NEW_PASSWORD);
    notifyListeners();
  }

}