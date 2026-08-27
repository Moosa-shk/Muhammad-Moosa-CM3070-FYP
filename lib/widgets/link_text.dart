// lib/widgets/link_text.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/colors.dart';
import 'popup_utils.dart';

/// Reusable rich text widget that automatically detects URLs
/// and converts them into interactive links.
///
/// Existing usage remains unchanged:
///
/// LinkText(
///   text,
///   style: ...,
///   linkStyle: ...,
/// )
class LinkText extends StatelessWidget {
  const LinkText(
    this.text, {
    super.key,
    required this.style,
    required this.linkStyle,
    this.maxLines,
  });

  final String text;

  /// Normal text styling supplied by the parent.
  final TextStyle style;

  /// Custom link styling supplied by the parent.
  final TextStyle linkStyle;

  final int? maxLines;

  // ===============================================================
  // URL DETECTION
  // ===============================================================

  static final RegExp _url = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  // ===============================================================
  // OPEN LINK
  // ===============================================================

  Future<void> _openUrl(String value) async {
    // Remove common punctuation that may appear directly
    // after a URL in normal sentences.
    final cleanedUrl = value.replaceFirst(
      RegExp(r'[.,!?;:]+$'),
      '',
    );

    final uri = Uri.tryParse(cleanedUrl);

    if (uri == null) {
      PopupUtils.warning(
        'Invalid Link',
        'This link could not be opened.',
      );
      return;
    }

    try {
      final canOpen = await canLaunchUrl(uri);

      if (!canOpen) {
        PopupUtils.warning(
          'Unable to Open Link',
          'No application is available to open this link.',
        );
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        PopupUtils.warning(
          'Unable to Open Link',
          'The link could not be opened.',
        );
      }
    } catch (_) {
      PopupUtils.error(
        'Link Error',
        'Something went wrong while opening the link.',
      );
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final matches = _url.allMatches(text).toList();

    // =============================================================
    // NORMAL TEXT
    // =============================================================

    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow:
            maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
      );
    }

    final spans = <InlineSpan>[];

    int currentIndex = 0;

    // =============================================================
    // CREATE RICH TEXT
    // =============================================================

    for (final match in matches) {
      // -----------------------------------------------------------
      // TEXT BEFORE URL
      // -----------------------------------------------------------

      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(
              currentIndex,
              match.start,
            ),
            style: style,
          ),
        );
      }

      final rawUrl = text.substring(
        match.start,
        match.end,
      );

      // Remove punctuation from actual clickable URL.
      final cleanUrl = rawUrl.replaceFirst(
        RegExp(r'[.,!?;:]+$'),
        '',
      );

      // Anything removed from the URL should remain visible as
      // normal punctuation after the clickable link.
      final trailingText = rawUrl.substring(
        cleanUrl.length,
      );

      // -----------------------------------------------------------
      // CLICKABLE URL
      // -----------------------------------------------------------

      spans.add(
        TextSpan(
          text: cleanUrl,

          style: linkStyle.copyWith(
            color: linkStyle.color ?? AppColor.primary,
            fontWeight: linkStyle.fontWeight ?? FontWeight.w800,
            decoration: TextDecoration.underline,
            decorationColor:
                (linkStyle.color ?? AppColor.primary).withOpacity(0.55),
            decorationThickness: 1.2,
          ),

          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _openUrl(cleanUrl);
            },
        ),
      );

      // -----------------------------------------------------------
      // TRAILING PUNCTUATION
      // -----------------------------------------------------------

      if (trailingText.isNotEmpty) {
        spans.add(
          TextSpan(
            text: trailingText,
            style: style,
          ),
        );
      }

      currentIndex = match.end;
    }

    // =============================================================
    // REMAINING TEXT
    // =============================================================

    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: style,
        ),
      );
    }

    // =============================================================
    // FINAL TEXT
    // =============================================================

    return Text.rich(
      TextSpan(
        style: style,
        children: spans,
      ),

      maxLines: maxLines,

      overflow:
          maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,

      textAlign: TextAlign.start,

      textScaler: MediaQuery.textScalerOf(context),
    );
  }
}