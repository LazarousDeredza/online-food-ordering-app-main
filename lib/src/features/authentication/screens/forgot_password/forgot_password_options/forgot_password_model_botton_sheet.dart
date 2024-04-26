import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import '../forgot_password_email/forgot_password_mail.dart';
import 'forgot_password_btn_widget.dart';

class ForgotPasswordScreen {
  static Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(tDefaultSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tForgotPasswordTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              tForgotPasswordSubTitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: tFormHeight,
            ),
            ForgotPasswordBtnWidget(
              btnIcon: Icons.email,
              title: tEmail,
              subTitle: tForgotEmailSubTitle,
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const ForgotPassordMailScreen());
              },
            ),
            const SizedBox(
              height: tFormHeight,
            ),
            ForgotPasswordBtnWidget(
              btnIcon: Icons.phone,
              title: tPhoneNumber,
              subTitle: tForgotPhoneSubTitle,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
