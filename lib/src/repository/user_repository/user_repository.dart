import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/src/features/authentication/models/user_model.dart';

/* 
Todo: to perform all database operations here
 */
class UserRespository extends GetxController {
  static UserRespository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

//fetch user details
  Future<UserModel> getUserDetails(String email) async {
    final snapshot =
        await _db.collection("users").where("email", isEqualTo: email).get();

    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;

    // Continue with further processing
    if (userData == null) {
      print("User not found");
    } else {
      print("User found");
    }

    return userData;
  }

  // //fetch all users
  // Future<List<UserModel>> getAllUsers() async {
  //   final snapshot = await _db.collection("users").get();
  //   final userData =
  //       snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
  //   return userData;
  // }

  Future<List<UserModel>> getAllUsers() async {
    String uid = FirebaseAuth.instance.currentUser!.uid.toString();
    print("Current User =$uid");
    final snapshot = await _db.collection("users").get();
    final userData = snapshot.docs
        .map((e) => UserModel.fromSnapshot(e))
        .where((user) => user.id != uid)
        .toList();
    return userData;
  }

  Future<List<UserModel>> getAllAdmins() async {
    String uid = FirebaseAuth.instance.currentUser!.uid.toString();
    print("Current User =$uid");
    final snapshot = await _db.collection("users").get();
    final userData = snapshot.docs
        .map((e) => UserModel.fromSnapshot(e))
        .where((user) => user.id != uid)
        .where((user) => user.level == "admin")
        .toList();
    return userData;
  }

  //update user details
  Future<void> updateUserRecord(UserModel user) async {
    print(user.id);
    final snapshot =
        await _db.collection("users").doc(user.id).update(user.toJson());

    Get.snackbar(
      "Success",
      "User updated successfully",
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
      ),
    );

    return snapshot;
  }
}
