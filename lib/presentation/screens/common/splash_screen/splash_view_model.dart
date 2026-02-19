// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';

class SplashViewModel extends ChangeNotifier {
  AnimationController? _controller;
  Animation<double>? animationTween;
  double size = 10;

  init() {
    // save();
    animate();
    onTap();
    _onLoad();
  }

  void animate() {}

  void onTap() {
    if (_controller!.status == AnimationStatus.completed) {
      _controller!.reverse();
    } else {
      _controller!.forward();
    }
    _controller!.dispose();
  }

  void _onLoad() async {
    await Future.delayed(const Duration(seconds: 4));
    _navigateNoNextPage();
  }

  _navigateNoNextPage() {
    // Get.offAllNamed(Routes.ONBOARDING_VIEW);
  }

  // void save() async {
  //   sharedPreferences!.setBool('splash', true);
  // }
}
