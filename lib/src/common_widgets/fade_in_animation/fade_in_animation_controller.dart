import "package:get/get.dart";
import "package:online_food_delivery_app/src/features/authentication/screens/welcome_screen/welcome_screen.dart";

class FadeInAnimationController extends GetxController {
  static FadeInAnimationController get find => Get.find();

  RxBool animate = false.obs;

  Future startSplashAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    animate.value = true;
    await Future.delayed(const Duration(milliseconds: 3000));
    animate.value = false;
    await Future.delayed(const Duration(milliseconds: 2000));

    Get.offAll(() => const WelcomeScreen());
    //Get.offAll(() => LoginPage());
  }

  Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    animate.value = true;
  }
}
