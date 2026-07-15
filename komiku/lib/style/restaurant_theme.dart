import 'package:flutter/material.dart';
import 'package:restaurapp/style/restaurant_colors.dart';
import 'package:restaurapp/style/restaurant_text_styles.dart';

class RestaurantTheme {
  static TextTheme get _textTheme {
    return TextTheme(
      titleLarge: RestaurantTextStyles.titleLarge,
      titleMedium: RestaurantTextStyles.titleMedium,
      titleSmall: RestaurantTextStyles.titleSmall,
      bodyLarge: RestaurantTextStyles.bodyLargeBold,
      bodyMedium: RestaurantTextStyles.bodyLargeMedium,
      bodySmall: RestaurantTextStyles.bodyLargeRegular,
      labelLarge: RestaurantTextStyles.labelLarge,
      labelMedium: RestaurantTextStyles.labelMedium,
      labelSmall: RestaurantTextStyles.labelSmall,
    );
  }

  static AppBarThemeData get _appBarTheme {
    return AppBarThemeData(
      toolbarTextStyle: _textTheme.titleMedium,
      centerTitle: true,
      titleTextStyle: _textTheme.titleLarge,
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: RestaurantColors.white.color,
        backgroundColor: RestaurantColors.blue.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      selectedItemColor: RestaurantColors.blue.color,
      unselectedItemColor: RestaurantColors.grey.color,
      selectedLabelStyle: _textTheme.labelMedium,
      unselectedLabelStyle: _textTheme.labelMedium,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      colorSchemeSeed: RestaurantColors.blue.color,
      brightness: Brightness.light,
      textTheme: _textTheme,
      useMaterial3: true,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorSchemeSeed: RestaurantColors.blue.color,
      brightness: Brightness.dark,
      textTheme: _textTheme,
      useMaterial3: true,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
    );
  }
}
