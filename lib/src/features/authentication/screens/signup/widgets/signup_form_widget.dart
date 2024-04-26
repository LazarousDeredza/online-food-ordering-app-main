import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import '../../../controllers/signup_controller.dart';
import '../../../models/user_model.dart';

class SignUpFormWidget extends StatelessWidget {
  const SignUpFormWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    final formKey = GlobalKey<FormState>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: tFormHeight),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //First Name
            TextFormField(
              controller: controller.firstName,
              decoration: const InputDecoration(
                labelText: "First Name",
                hintText: "Enter your first name",
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(
              height: tFormHeight - 20,
            ),
            //last name
            TextFormField(
              controller: controller.lastName,
              decoration: const InputDecoration(
                labelText: "Last Name",
                hintText: "Enter your last name",
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(
              height: tFormHeight - 20,
            ),
            //Email
            TextFormField(
              controller: controller.email,
              decoration: const InputDecoration(
                labelText: tEmail,
                hintText: "Enter your email",
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return 'Please enter your email';
                } else if (!GetUtils.isEmail(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(
              height: tFormHeight - 20,
            ),
            //phone
            TextFormField(
              controller: controller.phoneNo,
              decoration: const InputDecoration(
                labelText: tPhoneNumber,
                hintText: "Enter your phone number",
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(
              height: tFormHeight - 20,
            ),
            //password
            TextFormField(
              controller: controller.password,
              decoration: const InputDecoration(
                labelText: tPassword,
                hintText: "Enter password",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.remove_red_eye_sharp),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(
              height: tFormHeight - 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    String email = controller.email.text.trim();
                    String password = controller.password.text.trim();

                    String level = "user";
                    if (email == "foodordering461@gmail.com") {
                      // Set user level to admin
                      level = "admin";
                    }

                    final time =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    final user = UserModel(
                        firstName: controller.firstName.text.trim(),
                        lastName: controller.lastName.text.trim(),
                        email: controller.email.text.trim(),
                        phoneNo: controller.phoneNo.text.trim(),
                        password: controller.password.text.trim(),
                        level: level,
                        groups: [],
                        instGroups: [],
                        image: "",
                        createdAt: time,
                        name:
                            "${controller.firstName.text.trim()} ${controller.lastName.text.trim()}",
                        about: 'Hey there! I am using Foodie Delight',
                        isOnline: false,
                        lastActive: time,
                        pushToken: '');

                    SignUpController.instance.createUser(email, password, user);
                  }
                },
                child: Text(
                  tSignUpButton.toUpperCase(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFormattedDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(now);
  }
}
