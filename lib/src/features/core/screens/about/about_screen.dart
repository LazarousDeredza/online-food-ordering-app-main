import 'package:flutter/material.dart';
import 'package:online_food_delivery_app/src/constants/image_strings.dart';
import 'package:online_food_delivery_app/src/constants/text_strings.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LineAwesomeIcons.arrow_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("About"),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: 160,
              height: 160,
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(tSplashImage),
              ),
            ),
          ),
          Center(
            child: Text(
              "About Foodie Delight",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 20, bottom: 15, left: 10, right: 10),
                  child: Text(
                    tAbout,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          letterSpacing: .4,
                        ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
