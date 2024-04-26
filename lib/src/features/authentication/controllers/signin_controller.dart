import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/src/repository/authentication_repository/authentication_repository.dart';

class SignInController extends GetxController {
  static SignInController get instance => Get.find();

  final showPassword = false.obs;

  final isGoogleLoading = false.obs;
  final isLoading = false.obs;

  final email = TextEditingController();
  final password = TextEditingController();

  void loginuser(String email, String password) {
    print("Email: $email");
    print("Password: $password");

    isLoading.value = true;
    AuthenticationRepository.instance
        .loginWithEmailAndPassword(email, password);
    isLoading.value = false;
  }

//Google Login
  Future<void> googleSignIn() async {
    try {
      isGoogleLoading.value = true;
      await AuthenticationRepository.instance.signInWithGoogle();
      isGoogleLoading.value = false;
    } catch (e) {
      isGoogleLoading.value = false;
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
