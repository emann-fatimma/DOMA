import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class AppTextStyles {
  static TextStyle displayLogo({Color? color}) => GoogleFonts.urbanist(
    fontSize: 15, fontWeight: FontWeight.w900,
    letterSpacing: 5.0, color: color ?? Colors.white,
  );
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.urbanist(
    fontSize: 26, fontWeight: FontWeight.w800, color: color ?? AppColors.textDark,
  );
  static TextStyle headlineMedium({Color? color}) => GoogleFonts.urbanist(
    fontSize: 22, fontWeight: FontWeight.w800, color: color ?? AppColors.textDark,
  );
  static TextStyle titleLarge({Color? color}) => GoogleFonts.urbanist(
    fontSize: 18, fontWeight: FontWeight.w700, color: color ?? AppColors.textDark,
  );
  static TextStyle titleMedium({Color? color}) => GoogleFonts.urbanist(
    fontSize: 15, fontWeight: FontWeight.w700, color: color ?? AppColors.textDark,
  );
  static TextStyle buttonLabel({Color? color}) => GoogleFonts.urbanist(
    fontSize: 14, fontWeight: FontWeight.w700,
    letterSpacing: 2.0, color: color ?? Colors.white,
  );
  static TextStyle labelUppercase({Color? color}) => GoogleFonts.urbanist(
    fontSize: 10, fontWeight: FontWeight.w700,
    letterSpacing: 3.0, color: color ?? AppColors.primaryGreen,
  );
  static TextStyle price({Color? color}) => GoogleFonts.urbanist(
    fontSize: 26, fontWeight: FontWeight.w900, color: color ?? AppColors.accentOrange,
  );
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.cormorantGaramond(
    fontSize: 15, fontWeight: FontWeight.w500, color: color ?? AppColors.textMid,
  );
  static TextStyle bodyItalic({Color? color}) => GoogleFonts.cormorantGaramond(
    fontSize: 16, fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic, color: color ?? AppColors.textMid,
  );
  static TextStyle bodySmall({Color? color}) => GoogleFonts.cormorantGaramond(
    fontSize: 13, fontWeight: FontWeight.w400, color: color ?? AppColors.textLight,
  );
}