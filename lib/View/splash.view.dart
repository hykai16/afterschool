import 'dart:async';

import 'package:afterschool/View/login.view.dart';
import 'package:afterschool/utils/global.colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2),() {
      Get.to(LoginView());
    });
    return Scaffold(
      backgroundColor: GlobalColors.mainColor,
      body: const Center(
        child: Text(
          'After\nSchool',
          style: TextStyle(
            color: Colors.white,
            fontSize:40,
            fontWeight: FontWeight.bold,
            fontFamily: 'Dosis',
          ),
        ),
      ),
    );
  }
}
