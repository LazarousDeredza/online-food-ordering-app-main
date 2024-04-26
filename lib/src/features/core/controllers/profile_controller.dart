import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../repository/authentication_repository/authentication_repository.dart';
import '../../../repository/user_repository/user_repository.dart';
import '../../authentication/models/user_model.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRespository());
  //get user email and pass to userRepository to fetch user details
  getUserData() async {
    final email = _authRepo.firebaseUser.value?.email;
    if (email != null) {
      return _userRepo.getUserDetails(email);
    } else {
      Get.snackbar(
        "Error ",
        "User Not found",
      );
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    return _userRepo.getAllUsers();
  }

  Future<List<UserModel>> getAllAdmins() async {
    return _userRepo.getAllAdmins();
  }

  updateRecord(UserModel user) async {
    Get.snackbar(
      "Please wait",
      "Updating user details",
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(
        Icons.sync_rounded,
        color: Colors.green,
      ),
    );
    await _userRepo.updateUserRecord(user);
  }
}
