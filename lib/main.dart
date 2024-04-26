import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:online_food_delivery_app/firebase_options.dart';
import 'package:online_food_delivery_app/src/features/authentication/screens/onboard/onboard.dart';
import 'package:online_food_delivery_app/src/repository/authentication_repository/authentication_repository.dart';
import 'package:online_food_delivery_app/src/utils/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

int? isviewed;
late Size mq;

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');
  isviewed == 0
      ? Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
          .then((value) => Get.put(AuthenticationRepository()))
      : null;

// Set preferred orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const App());
  });
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<App> {
// @override
//   void initState() {
//     super.initState();
//     getUserLoggedInStatus();
//   }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodie Delight',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      defaultTransition: Transition.leftToRightWithFade,
      transitionDuration: const Duration(milliseconds: 500),
      home: isviewed != 0
          ? const OnBoard()
          : SizedBox(
              width: 20, // Adjust the width to make it smaller
              height: 20, // Adjust the height to make it smaller
              child: Transform.scale(
                scale:
                    0.2, // Adjust the scale factor to make the indicator smaller
                child: const CircularProgressIndicator(
                  strokeWidth:
                      2, // Adjust the strokeWidth to change the thickness of the progress indicator
                  valueColor: AlwaysStoppedAnimation<Color>(Colors
                      .blue), // Change the color of the progress indicator
                ),
              ),
            ),
      // home: isviewed != 0 ? OnBoard() : SplashScreen(),
    );
  }

  //  getUserLoggedInStatus() async{
  //  }
}
