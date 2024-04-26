import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/src/constants/sizes.dart';
import 'package:online_food_delivery_app/src/features/authentication/controllers/mail_verification_controller.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/login/login.dart';

class MailVerificationScreen extends StatelessWidget {
  const MailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MailVerificationController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: tDefaultSize * 5,
            left: tDefaultSize,
            right: tDefaultSize,
            bottom: tDefaultSize * 2,
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Icon(
              Icons.mail_outline,
              size: 100,
            ),
            const SizedBox(
              height: tDefaultSize * 2,
            ),
            Text("Verify your email",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(
              height: tDefaultSize,
            ),
            Text(
                "We have sent a verification link to your email address. Please click on the link to verify your email address.",
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(
              height: tDefaultSize * 2,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.manualCheck();
                },
                child: const Text("Continue"),
              ),
            ),
            const SizedBox(
              height: tDefaultSize * 2,
            ),
            Text("Didn't receive the email?",
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(
              height: tDefaultSize,
            ),
            TextButton(
              onPressed: () {
                controller.sendVerificationLink();
              },
              child: const Text("Resend Link"),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => const LoginScreen());
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back),
                  Text("Back to Login"),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
