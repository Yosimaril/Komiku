import 'package:flutter/material.dart';
import 'package:komiku/style/komiku_colors.dart';

class KomikuTheme {
  static AppBarThemeData get _appBarTheme {
    return AppBarThemeData(centerTitle: true);
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: KomikuColors.white.color,
        backgroundColor: KomikuColors.blue.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      selectedItemColor: KomikuColors.blue.color,
      unselectedItemColor: KomikuColors.grey.color,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      colorSchemeSeed: KomikuColors.blue.color,
      brightness: Brightness.light,
      useMaterial3: true,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorSchemeSeed: KomikuColors.blue.color,
      brightness: Brightness.dark,
      useMaterial3: true,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
    );
  }
}
