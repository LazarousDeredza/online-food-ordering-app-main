import 'package:flutter/material.dart';
import 'package:online_food_delivery_app/src/constants/sizes.dart';

import '../../../../constants/colors.dart';
import '../../models/model_on_boarding.dart';

class onBoardingPageWidget extends StatelessWidget {
  const onBoardingPageWidget({
    super.key,
    required this.model,
  });

  final onBoardingModel model;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(tDefaultSize),
      color: tOnboardingPage1Color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image(
            image: AssetImage(model.image),
            height: size.height * 0.4,
          ),
          Column(
            children: [
              Text(
                model.title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                model.subTitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Text(
            model.counterText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 50.0,
          ),
        ],
      ),
    );
  }
}
