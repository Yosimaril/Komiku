import 'package:flutter/material.dart';

class RatingStar extends StatelessWidget {
  const RatingStar({super.key, required this.ratingAverage});

  final double ratingAverage;

  @override
  Widget build(BuildContext context) {
    final full = ratingAverage.floor().clamp(0, 5);
    final hasHalf = (ratingAverage - full) >= 0.25;
    String stars = '';
    for (int i = 0; i < 5; i++) {
      if (i < full) {
        stars += '★';
      } else if (i == full && hasHalf) {
        stars += '⯪';
      } else {
        stars += '☆';
      }
    }

    return Row(
      children: [
        Text(stars, style: const TextStyle(color: Colors.amber, fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          ratingAverage.toStringAsFixed(1),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
