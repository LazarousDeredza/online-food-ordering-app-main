import 'dart:convert';

import 'package:online_food_delivery_app/src/features/core/screens/personal_chat/models/chat_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityGroupHelperFunctions {
  //keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  // saving the data to SF

  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  // getting the data from SF

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  static Future<bool?> saveUserToPref(ChatUser user) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    String userString =
        jsonEncode(user.toJson()); // Convert ChatUser to JSON string
    return await sf.setString("user", userString);
  }

  static Future<ChatUser?> getUserFromPref() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    String? userString = sf.getString('user');
    if (userString != null) {
      Map<String, dynamic> userJson =
          jsonDecode(userString); // Convert JSON string to Map
      return ChatUser.fromJson(userJson); // Convert Map to ChatUser object
    }
    return null;
  }
}
