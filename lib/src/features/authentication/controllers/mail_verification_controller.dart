import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/login/login.dart';
import 'package:online_food_delivery_app/src/repository/authentication_repository/authentication_repository.dart';

class MailVerificationController extends GetxController {
  late Timer _timer;

  final _authRepo = Get.put(AuthenticationRepository());


  void manualCheck() {
    FirebaseAuth.instance.currentUser!.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user!.emailVerified) {
      _timer.cancel();
      Get.offAll(() => const LoginScreen());
    } else {
      Get.snackbar(
        "Email Not Verified Yet",
        "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(
          Icons.warning,
          color: Colors.white,
        ),
      );
      print("Email Not Verified Yet");
    }
  }

  void sendVerificationLink() async {
    await _authRepo.sendVerificationLink();
  }
}
