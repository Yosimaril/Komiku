import 'package:flutter/widgets.dart';

class RestaurantTextStyles {
  static const TextStyle _baseStyle = TextStyle(fontFamily: 'Merriweather');

  static TextStyle titleLarge = _baseStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 1.0,
  );

  static TextStyle titleMedium = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.2,
  );

  static TextStyle titleSmall = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.4,
  );

  static TextStyle bodyLargeBold = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  static TextStyle bodyLargeMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static TextStyle bodyLargeRegular = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.3,
  );

  static TextStyle labelMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 1.3,
  );

  static TextStyle labelSmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 1.3,
  );
}
