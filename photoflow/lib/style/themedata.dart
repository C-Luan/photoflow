// Define your color palette in a constants file
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color.fromARGB(255, 25, 52, 95);
  static const Color primaryLight = Color.fromARGB(255, 45, 78, 131);
  static const Color primaryDark = Color.fromARGB(255, 15, 33, 61);
  static const Color primaryLightest = Color.fromARGB(255, 229, 234, 242);

  // Accent Colors
  static const Color accent1 = Color.fromARGB(255, 74, 137, 220);
  static const Color accent2 = Color.fromARGB(255, 255, 138, 101);
  static const Color accent3 = Color.fromARGB(255, 38, 198, 218);
  static const Color accent4 = Color.fromARGB(255, 255, 202, 40);

  // Neutral Colors
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color gray100 = Color.fromARGB(255, 248, 249, 250);
  static const Color gray300 = Color.fromARGB(255, 222, 226, 230);
  static const Color gray600 = Color.fromARGB(255, 108, 117, 125);
  static const Color gray900 = Color.fromARGB(255, 33, 37, 41);

  // Semantic Colors
  static const Color success = Color.fromARGB(255, 46, 204, 113);
  static const Color warning = Color.fromARGB(255, 243, 156, 18);
  static const Color danger = Color.fromARGB(255, 231, 76, 60);
  static const Color info = Color.fromARGB(255, 52, 152, 219);
}

class AppDarkColors {
  // Primary Colors
  static const Color primary = Color.fromARGB(255, 26, 73, 128);
  static const Color primaryLight = Color.fromARGB(255, 45, 92, 153);
  static const Color primaryDark = Color.fromARGB(255, 14, 42, 77);
  static const Color surface = Color.fromARGB(255, 18, 28, 46);

  // Accent Colors
  static const Color accent1 = Color.fromARGB(255, 91, 157, 241);
  static const Color accent2 = Color.fromARGB(255, 255, 159, 122);
  static const Color accent3 = Color.fromARGB(255, 48, 216, 237);
  static const Color accent4 = Color.fromARGB(255, 255, 213, 79);

  // Neutral Colors
  static const Color background = Color.fromARGB(255, 18, 18, 18);
  static const Color surfaceVariant = Color.fromARGB(255, 30, 30, 30);
  static const Color gray700 = Color.fromARGB(255, 66, 66, 66);
  static const Color gray400 = Color.fromARGB(255, 160, 160, 160);
  static const Color white = Color.fromARGB(255, 224, 224, 224);

  // Semantic Colors
  static const Color success = Color.fromARGB(255, 46, 224, 125);
  static const Color warning = Color.fromARGB(255, 255, 183, 77);
  static const Color danger = Color.fromARGB(255, 255, 82, 82);
  static const Color info = Color.fromARGB(255, 79, 195, 247);
}

ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
    useMaterial3: false,
    primaryColor: AppDarkColors.primary,
    scaffoldBackgroundColor: AppDarkColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppDarkColors.primary,
      foregroundColor: AppDarkColors.white,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppDarkColors.primary,
      secondary: AppDarkColors.accent3,
      error: AppDarkColors.danger,
      surface: AppDarkColors.surface,
      onSurface: AppDarkColors.white,
    ),
    cardColor: AppDarkColors.surfaceVariant,
    dialogBackgroundColor: AppDarkColors.surfaceVariant,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 71, 121, 233),
        foregroundColor: AppDarkColors.white,
      ),
    ),
    // Add more theme customizations as needed
  );
}

// Example theme implementation
ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: false,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.gray100,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent3,
      error: AppColors.danger,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 71, 121, 233),
        foregroundColor: AppColors.white,
      ),
    ),
    // Add more theme customizations as needed
  );
}
