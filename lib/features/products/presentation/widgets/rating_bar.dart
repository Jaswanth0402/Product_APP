import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  const RatingBar({super.key, required this.rating, this.size = 18});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = rating - index;
        return Icon(
          filled >= 1
              ? Icons.star_rounded
              : filled >= 0.5
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color: Colors.amber,
        );
      }),
    );
  }
}
