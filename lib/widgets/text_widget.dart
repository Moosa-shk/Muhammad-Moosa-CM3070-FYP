// lib/widgets/text_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/colors.dart';

/// TextWidget
///
/// A reusable custom text component used across the DisasterAid application.
/// It standardizes typography by applying the **Plus Jakarta Sans** font
/// and predefined styling options.
///
/// Advantages of using this widget:
/// • Ensures consistent typography across the entire app
/// • Reduces repetitive TextStyle code
/// • Allows flexible customization (size, color, weight, alignment)
/// • Improves maintainability of UI design
class TextWidget extends StatelessWidget {

  /// The text content to be displayed
  final String text;

  /// Font size of the text
  final double size;

  /// Font weight (e.g., bold, medium)
  final FontWeight weight;

  /// Optional color override
  /// If not provided, the default app text color is used
  final Color? color;

  /// Text alignment within the widget
  final TextAlign align;

  /// Maximum number of lines allowed before truncation
  final int? maxLines;

  /// Overflow behavior when text exceeds max lines
  final TextOverflow? overflow;

  /// Constructor with configurable parameters
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

      /// Align text horizontally
      textAlign: align,

      /// Restrict number of lines if specified
      maxLines: maxLines,

      /// Define overflow behavior (ellipsis, fade, etc.)
      overflow: overflow,

      /// Apply Google Fonts styling
      /// Plus Jakarta Sans provides a modern readable font
      style: GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,

        /// Use custom color or fallback to default theme text color
        color: color ?? AppColor.text,
      ),
    );
  }
}