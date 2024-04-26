import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/login/widgets/social_button.dart';

import '../../../../../constants/image_strings.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import '../../../controllers/signin_controller.dart';
import '../../signup/signup_screen.dart';

class LoginFooterWidget extends StatelessWidget {
  LoginFooterWidget({
    super.key,
  });

  var controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "OR",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          height: tDefaultSize - 20,
        ),
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
        const SizedBox(
          height: tDefaultSize - 20,
        ),
        TextButton(
          onPressed: () {
            Get.to(() => const SignUpScreen());
          },
          child: Text.rich(
            TextSpan(
              text: tDontHaveAnAccount,
              style: Theme.of(context).textTheme.bodyLarge,
              children: const [
                TextSpan(
                  text: tSignUp,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
