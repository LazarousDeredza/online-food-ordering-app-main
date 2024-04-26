import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(

        side: const BorderSide(color: tSecondaryColor),
        foregroundColor: tSecondaryColor,
        padding: const EdgeInsets.symmetric(vertical: tButtonHeight)),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
        side: const BorderSide(color: tWhiteColor),
        foregroundColor: tWhiteColor,
        padding: const EdgeInsets.symmetric(vertical: tButtonHeight)),
  );
}
