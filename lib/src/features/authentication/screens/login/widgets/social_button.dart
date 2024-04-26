import 'package:flutter/material.dart';

import 'button_loading_widget.dart';

class TSocialButton extends StatelessWidget {
  const TSocialButton({
    super.key,
    required this.text,
    required this.image,
    required this.foregroundColor,
    required this.background,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final String image;
  final Color foregroundColor, background;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: foregroundColor,
          backgroundColor: background,
          side: BorderSide.none,
        ),
        icon: isLoading
            ? const SizedBox()
            : Image(
                image: AssetImage(image),
                height: 24,
                width: 24,
              ),
        label: isLoading
            ? const ButtonLoadingWidget()
            : Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .apply(color: foregroundColor),
              ),
      ),
    );
  }
}
