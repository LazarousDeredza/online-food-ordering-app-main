import 'package:flutter/material.dart';

class FormHeaderWidget extends StatelessWidget {
  const FormHeaderWidget({
    super.key,
    this.imageColor,
    this.imageHeight = 0.2,
    this.heightBetween,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final Color? imageColor;
  final double imageHeight;
  final double? heightBetween;
  final String image, title, subTitle;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Center(
          child: Image(
            image: AssetImage(image),
            height: size.height * imageHeight,
            color: imageColor,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
          height: heightBetween,
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        Text(
          subTitle,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: textAlign,
        ),
      ],
    );
  }
}
