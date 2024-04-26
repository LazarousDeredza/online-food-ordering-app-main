import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_food_delivery_app/src/constants/colors.dart';

class TTextTheme {
  TTextTheme._();

  //light theme
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: tDarkColor,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: tDarkColor,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: tDarkColor,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: tDarkColor,
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: tDarkColor,
    ),
    titleLarge: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: tDarkColor,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: tDarkColor,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: tDarkColor,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: tDarkColor,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: tDarkColor,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: tWhiteColor,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: tWhiteColor,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: tWhiteColor,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: tWhiteColor,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: tWhiteColor,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: tWhiteColor,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: tWhiteColor,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: tWhiteColor,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: tWhiteColor,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: tWhiteColor,
    ),
  );
}
