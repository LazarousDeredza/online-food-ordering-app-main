import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/login/login.dart';

import '../../../../../constants/image_strings.dart';
import '../../../../../constants/text_strings.dart';
import '../../../controllers/signin_controller.dart';
import '../../login/widgets/social_button.dart';

class signup_footer_widget extends StatelessWidget {
  const signup_footer_widget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(SignInController());
    return Column(
      children: [
        const Text("OR"),
        Obx(
          () => TSocialButton(
            text: "Sign in with Google",
            image: tGoogleLogoImage,
            foregroundColor: Colors.black,
            background: Colors.white,
            isLoading: controller.isGoogleLoading.value ? true : false,
            onPressed:
                controller.isGoogleLoading.value || controller.isLoading.value
                    ? () {
                        print("Google Sign in is loading");
                      }
                    : () {
                        controller.googleSignIn();
                      },
          ),
        ),
        TextButton(
          onPressed: () {
            Get.offAll(() => const LoginScreen());
          },
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: tAlreadyHaveAnAccount,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                TextSpan(
                  text: tLogin.toUpperCase(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
