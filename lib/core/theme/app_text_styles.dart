import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1 = GoogleFonts.nunitoSans(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.nunitoSans(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.nunitoSans(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySecondary = GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = GoogleFonts.nunitoSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}