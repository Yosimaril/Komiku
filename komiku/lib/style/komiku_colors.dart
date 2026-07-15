import 'package:flutter/material.dart';

enum KomikuColors {
  blue("Blue", Color(0xFF305689)),
  white("White", Colors.white),
  grey("Grey", Colors.grey),
  lightWhite("Light White", Color(0xFFF5F5F5));

  final String name;
  final Color color;

  const KomikuColors(this.name, this.color);
}
