import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/login/login.dart';
import 'package:online_food_delivery_app/src/features/core/services/helper/helper_function.dart';
import 'package:online_food_delivery_app/src/features/core/screens/personal_chat/api/apis.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/mail_verification/mail_verifcation.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:online_food_delivery_app/src/features/core/screens/dashboard/dashboard.dart';
import 'package:online_food_delivery_app/src/repository/authentication_repository/exceptions/signup_email_password.dart';
import 'package:intl/intl.dart';

import '../../features/authentication/models/user_model.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;
  final verificationId = ''.obs;
  final _db = FirebaseFirestore.instance;

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());

    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    var result = await FlutterNotificationChannel.registerNotificationChannel(
        description: 'For Showing Message Notification',
        id: 'chats',
        importance: NotificationImportance.IMPORTANCE_HIGH,
        name: 'Chats');
    print('\nNotification Channel Result: $result');

    if (user == null) {
      Get.offAll(() => const SplashScreen());
    } else {
      //Get.offAll(() => Dashboard());
      if (user.emailVerified) {
        Get.offAll(() => const Dashboard());
        // Get.offAll(() => HomeScreen());
      } else {
        print("Email not verified");
        //Get.offAll(() => LoginScreenChat());
        Get.offAll(() => const MailVerificationScreen());
      }
    }
  }

  Future<bool> verifyOTP(String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value, smsCode: otp);
    var credintials = await _auth.signInWithCredential(credential);

    return credintials.user != null ? true : false;
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, UserModel user) async {
    try {
      Get.snackbar(
        'Please Wait',
        'Creating Account...',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Send email verification
        await firebaseUser.sendEmailVerification();

        String Uid = firebaseUser.uid;
        print(Uid);

        // Save user to database
        await createUser(user, Uid);
      }
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      Get.snackbar(
        "Error Creating An Account",
        ex.message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      print(ex.message);
      //throw ex.message;
    } catch (_) {
      Get.snackbar(
        "Error Creating Account",
        _.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      //throw _;
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      Get.snackbar("Signing In", "Please wait...",
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.BOTTOM);

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (firebaseUser.value != null) {
        User? firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser!.emailVerified) {
          Get.snackbar("Success", "Signed in successfully",
              backgroundColor: Colors.green,
              colorText: Colors.black,
              snackPosition: SnackPosition.BOTTOM);

          await CommunityGroupHelperFunctions.saveUserLoggedInStatus(true);
          await CommunityGroupHelperFunctions.saveUserEmailSF(email);

          //get first and last name from firebase users collection where email matches
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get()
              .then((value) {
            CommunityGroupHelperFunctions.saveUserNameSF(
                value.docs[0]['firstName'] + " " + value.docs[0]['lastName']);
          });

          Get.offAll(() => const Dashboard());
        } else {
          print("Email not verified");

          //  Get.offAll(() => LoginScreen());
          Get.snackbar(
            'Error',
            'Please Verify your email.',
            backgroundColor: Colors.yellowAccent,
            colorText: Colors.black,
            duration: const Duration(seconds: 8),
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        // Get.snackbar("Success", "Signed in successfully",
        //     backgroundColor: Colors.green,
        //     colorText: Colors.black,
        //     snackPosition: SnackPosition.BOTTOM);
        // Get.offAll(() => Dashboard());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error Signing In",
        e.message.toString(),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      );
      //throw e;
    } catch (_) {
      Get.snackbar("Error Signing In", _.toString(),
          snackPosition: SnackPosition.BOTTOM);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut().whenComplete(() {});
      await GoogleSignIn.standard().signOut();

      if (firebaseUser.value == null) {
        Get.snackbar("Success", "Signed out successfully",
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
        //wait 3 seconds
        await Future.delayed(const Duration(seconds: 3));

        //Get.offAll(() => WelcomeScreen());
      }
    } catch (e) {
      Get.snackbar("Error signing out", e.toString(),
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  createUser(UserModel user, String Uid) async {
    // saving the userdata

    await _db.collection('users').doc(Uid).set({
      "id": Uid,
      "firstName": user.firstName,
      "lastName": user.lastName,
      "name": user.name,
      "email": user.email,
      "phone": user.phoneNo,
      "password": user.password,
      "level": user.level,
      "groups": user.groups,
      "instGroups": user.instGroups,
      "image": user.image,
      "created_at": user.createdAt,
      "about": user.about,
      "is_online": user.isOnline,
      "last_active": user.lastActive,
      "push_token": user.pushToken,
    }).whenComplete(() async {
      print("User created successfully");

      await CommunityGroupHelperFunctions.saveUserLoggedInStatus(true);
      await CommunityGroupHelperFunctions.saveUserEmailSF(user.email);
      await CommunityGroupHelperFunctions.saveUserNameSF(user.name);

      Get.snackbar(
        'Success',
        'Account Was Created Successfully\nOpen your Email and verify your account',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => const MailVerificationScreen());
    }).catchError((error, printTrace) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      print("Error: $error");
    });
  }

  Future<void> sendResetLink(String email) async {
    Get.snackbar(
      'Please Wait',
      'Checking $email',
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );

    try {
      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar(
        'Success',
        'Reset link sent to $email',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        onTap: (_) {
          // Snackbar tapped
          //Get.offAll(() => LoginScreenChat());
        },
      );
      // Get.offAll(() => LoginScreenChat());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        _.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> sendVerificationLink() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // Send email verification
      await firebaseUser.sendEmailVerification();

      print("Verification Link sent Successfully to : ${firebaseUser.email}");
      // Save user to database
      Get.snackbar("Sucess",
          "Verification Link sent Successfully to : ${firebaseUser.email}",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    UserCredential? cr;
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential

      cr = await FirebaseAuth.instance.signInWithCredential(credential);

      //get User Details
      final user = FirebaseAuth.instance.currentUser;
      String? userEmail = user?.email.toString();
      String? userDisplayName = user?.displayName.toString();

      print(user?.email.toString());
      print(user?.displayName.toString());
      print(user?.photoURL.toString());
      print(user?.phoneNumber.toString());

      await CommunityGroupHelperFunctions.saveUserLoggedInStatus(true);
      await CommunityGroupHelperFunctions.saveUserEmailSF(userEmail!);
      await CommunityGroupHelperFunctions.saveUserNameSF(userDisplayName!);

      if (user != null) {
        String Uid = user.uid;
        print(Uid);
        // Save user to database
        String firstName = user.displayName.toString().split(" ")[0];
        String lastName = user.displayName.toString().split(" ")[1];

        final time = DateTime.now().millisecondsSinceEpoch.toString();

        String userlevel = "user";

        if (userEmail == "ninja.ld49@gmail.com" ||
            userEmail == "foodordering461@gmail.com") {
          // Set user level to admin
          userlevel = "admin";
        }

        UserModel userModel = UserModel(
            firstName: firstName,
            lastName: lastName,
            email: user.email.toString(),
            phoneNo: user.phoneNumber.toString(),
            password: "",
            level: userlevel,
            groups: [],
            instGroups: [],
            image: user.photoURL.toString(),
            createdAt: time,
            name: user.displayName.toString(),
            about: 'Hey There I am using Foodie Delight',
            isOnline: false,
            lastActive: time,
            pushToken: '');

        if ((await APIs.userExists())) {
          print("User Already Exists");

          Get.snackbar(
            'Success',
            'Signed in successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Get.offAll(() => Dashboard());
        } else {
          await _db
              .collection('users')
              .doc(Uid)
              .set({
                "id": Uid,
                "firstName": userModel.firstName,
                "lastName": userModel.lastName,
                "name": userModel.name,
                "email": userModel.email,
                "phone": userModel.phoneNo,
                "password": userModel.password,
                "level": userModel.level,
                "groups": userModel.groups,
                "instGroups": userModel.instGroups,
                "image": userModel.image,
                "created_at": userModel.createdAt,
                "about": userModel.about,
                "is_online": userModel.isOnline,
                "last_active": userModel.lastActive,
                "push_token": userModel.pushToken,
              })
              .then((value) => () {
                    print("User Created Successfully");
                    Get.snackbar(
                      'Success',
                      'Account Was Created Successfully',
                      duration: const Duration(seconds: 3),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  })
              .onError((error, stackTrace) => () {
                    print("Auth login Error : $error");

                    Get.snackbar(
                      'Error',
                      error.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      colorText: Colors.red,
                    );
                    print("Error: $error");
                  });
        }
      }
    } on FirebaseAuthException catch (e) {
      Get.offAll(() => const LoginScreen());

      print("Auth login Error 1 : $e");

      Get.snackbar(
        'Error',
        e.message.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return null;
    } on PlatformException catch (e) {
      Get.offAll(() => const LoginScreen());

      print("Auth login Error 2 : $e");

      Get.snackbar("Error", e.message.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return null;
    } catch (_) {
      Get.offAll(() => const LoginScreen());
      print("Auth login Error 3 : $_");

      Get.snackbar(
        'Error',
        _.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );

      return null;
    }
    return cr;
  }

  String getFormattedDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(now);
  }
}
