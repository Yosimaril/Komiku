import 'package:flutter/material.dart';

enum RestaurantColors {
  blue("Blue", Colors.blue),
  white("White", Colors.white),
  grey("Grey", Colors.grey);

  final String name;
  final Color color;

  const RestaurantColors(this.name, this.color);
}
