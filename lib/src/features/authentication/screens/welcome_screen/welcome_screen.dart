import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/src/common_widgets/fade_in_animation/animation_design.dart';
import 'package:online_food_delivery_app/src/constants/colors.dart';
import 'package:online_food_delivery_app/src/constants/image_strings.dart';
import 'package:online_food_delivery_app/src/constants/sizes.dart';
import 'package:online_food_delivery_app/src/constants/text_strings.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/signup/signup_screen.dart';

import '../../../../common_widgets/fade_in_animation/fade_in_animation_controller.dart';
import '../../../../common_widgets/fade_in_animation/fade_in_animation_model.dart';
import '../login/login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadeInAnimationController());
    controller.startAnimation();

    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? tDarkColor : tWhiteColor,
      body: Stack(
        children: [
          TFadeInAnimation(
            durationInMs: 1200,
            animate: TAnimationPosition(
              bottomAfter: 0,
              bottomBefore: -100,
              rightAfter: 0,
              rightBefore: 0,
              topAfter: 0,
              topBefore: 0,
              leftAfter: 0,
            ),
            child: Container(
              padding: const EdgeInsets.all(tDefaultSize),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Image(
                      image: const AssetImage(tWelcomeScreenImage),
                      height: height * 0.5,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        tWelcomeTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        tWelcomeSubTitle,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 900, // Replace with your desired width
                    child: Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  // Get.to(() => const LoginScreenChat()),
                                  Get.to(() => const LoginScreen()),
                              child: Text(tLogin.toUpperCase()),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Get.to(() => const SignUpScreen()),
                              child: Text(
                                tSignUp.toUpperCase(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
