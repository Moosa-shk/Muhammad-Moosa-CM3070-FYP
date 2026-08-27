// lib/widgets/text_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/colors.dart';

/// Reusable typography widget.
///
/// Public API is unchanged.
class TextWidget extends StatelessWidget {
  final String text;

  final double size;

  final FontWeight weight;

  final Color? color;

  final TextAlign align;

  final int? maxLines;

  final TextOverflow? overflow;

  const TextWidget(
    this.text, {
    super.key,
    this.size = 16,
    this.weight = FontWeight.w500,
    this.color,
    this.align = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,

      textAlign: align,

      maxLines: maxLines,

      overflow: overflow,

      style: GoogleFonts.plusJakartaSans(
        fontSize: size,

        fontWeight: weight,

        color: color ?? AppColor.text,

        height: _heightForSize(size),

        letterSpacing: _spacingForSize(
          size,
          weight,
        ),
      ),
    );
  }

  double _heightForSize(double value) {
    if (value >= 26) {
      return 1.08;
    }

    if (value >= 20) {
      return 1.16;
    }

    if (value >= 16) {
      return 1.35;
    }

    return 1.40;
  }

  double _spacingForSize(
    double value,
    FontWeight fontWeight,
  ) {
    if (value >= 26) {
      return -0.65;
    }

    if (value >= 20) {
      return -0.30;
    }

    if (value >= 17 &&
        fontWeight.index >= FontWeight.w700.index) {
      return -0.10;
    }

    return 0;
  }
}