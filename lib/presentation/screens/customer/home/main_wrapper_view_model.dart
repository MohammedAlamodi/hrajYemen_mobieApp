import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/profile_view_model.dart';

class MainWrapperViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changePage({required BuildContext context,required int index}) {
    if (_currentIndex != index) {
      debugPrint('Changing page from $_currentIndex to $index');
      _currentIndex = index;
      notifyListeners();

      ProfileViewModel profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      if(index == 3 ) {
        debugPrint('User is not logged in, redirecting to GuestScreen');
        profileViewModel.initData();
      }
    }
  }
}