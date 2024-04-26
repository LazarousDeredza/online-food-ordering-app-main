import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../repository/authentication_repository/authentication_repository.dart';
import '../../core/screens/dashboard/dashboard.dart';

class OTPController extends GetxController {
  static OTPController get instance => Get.find();

  void verifyOTP(String otp) async {
    var isVerified = await AuthenticationRepository.instance.verifyOTP(otp);

    if (isVerified) {
      Get.snackbar("Sucess", "Verification Completed",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          colorText: Colors.black,
          backgroundColor: Colors.greenAccent);
      Get.offAll(() => const Dashboard());
    } else {
      Get.snackbar(
        "Error",
        "Invalid OTP",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        colorText: Colors.black,
        backgroundColor: Colors.redAccent,
      );
      Get.back();
    }
  }
}
