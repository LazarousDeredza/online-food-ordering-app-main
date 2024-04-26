import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:online_food_delivery_app/main.dart';
import 'package:online_food_delivery_app/src/common_widgets/fade_in_animation/animation_design.dart';
import 'package:online_food_delivery_app/src/constants/colors.dart';
import 'package:online_food_delivery_app/src/constants/image_strings.dart';
import 'package:online_food_delivery_app/src/constants/sizes.dart';
import 'package:online_food_delivery_app/src/constants/text_strings.dart';

import '../../../../common_widgets/fade_in_animation/fade_in_animation_controller.dart';
import '../../../../common_widgets/fade_in_animation/fade_in_animation_model.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // final splashController = Get.put(TFadeInAnimationController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadeInAnimationController());
    controller.startSplashAnimation();
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            TFadeInAnimation(
                durationInMs: 1600,
                animate: TAnimationPosition(
                  topBefore: -30,
                  topAfter: 0,
                  leftBefore: -30,
                  leftAfter: 0,
                ),
                child: const Image(
                  image: AssetImage(tSplashTopIcon),
                  height: 70,
                )),
            TFadeInAnimation(
              durationInMs: 2000,
              animate: TAnimationPosition(
                topBefore: 80,
                topAfter: 80,
                leftBefore: -80,
                leftAfter: tDefaultSize,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tAppName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    tAppTagLine,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            TFadeInAnimation(
              durationInMs: 2400,
              animate: TAnimationPosition(
                bottomBefore: 0,
                bottomAfter: 100,
              ),
              child: Image(
                width: mq.width,
                image: const AssetImage(tSplashImage2),
              ),
            ),
            TFadeInAnimation(
              durationInMs: 2400,
              animate: TAnimationPosition(
                bottomBefore: 0,
                bottomAfter: 60,
                rightBefore: tDefaultSize,
                rightAfter: tDefaultSize,
              ),
              child: Container(
                width: tSplashContainerSize,
                height: tSplashContainerSize,
                decoration: BoxDecoration(
                  color: tPrimaryColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
