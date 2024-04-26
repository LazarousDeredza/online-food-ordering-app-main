import 'package:flutter/material.dart';

class MyImageWidget extends StatelessWidget {
  final String imageUrl;

  const MyImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // Replace with your desired width
      height: 200, // Replace with your desired height
      child: Image.network(
        imageUrl,
        fit: BoxFit.fill,
      ),
    );
  }
}
