import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapshare_mobile/utils/colors.dart';

class AppTheme {
  static TextTheme lightTextTheme = TextTheme(
    bodyLarge: GoogleFonts.openSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    bodyLarge: GoogleFonts.openSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  );

  static ThemeData light() {
    return ThemeData.light();
  }

  static ThemeData dark() {
    return ThemeData.dark()
        .copyWith(scaffoldBackgroundColor: mobileBackgroundColor);
  }
}
