// lib/widgets/link_text.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// LinkText widget displays text that may contain URLs.
/// If a URL is detected, it becomes a clickable link that
/// opens in the device's external browser.
class LinkText extends StatelessWidget {
  const LinkText(
    this.text, {
    super.key,
    required this.style,
    required this.linkStyle,
    this.maxLines,
  });

  /// Text content that may contain URLs
  final String text;

  /// Default text style for normal text
  final TextStyle style;

  /// Style used for clickable links
  final TextStyle linkStyle;

  /// Optional maximum number of lines to display
  final int? maxLines;

  /// Regular expression used to detect URLs in the text
  static final _url = RegExp(r'(https?:\/\/[^\s]+)');

  @override
  Widget build(BuildContext context) {

    /// List of text spans used to build the rich text widget
    final spans = <TextSpan>[];

    /// Find all URLs in the provided text
    final matches = _url.allMatches(text).toList();

    /// If no URLs exist, display plain text
    if (matches.isEmpty) {
      return Text(text, style: style, maxLines: maxLines);
    }

    int idx = 0;

    /// Process text and convert detected URLs into clickable spans
    for (final m in matches) {

      /// Add normal text before the detected URL
      if (m.start > idx) {
        spans.add(
          TextSpan(
            text: text.substring(idx, m.start),
            style: style,
          ),
        );
      }

      /// Extract the detected URL
      final url = text.substring(m.start, m.end);

      /// Create a clickable link span
      spans.add(
        TextSpan(
          text: url,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {

              /// Convert URL string into URI
              final uri = Uri.tryParse(url);

              /// If URL is invalid, do nothing
              if (uri == null) return;

              /// Launch the URL in the external browser
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            },
        ),
      );

      /// Update index after the processed URL
      idx = m.end;
    }

    /// Add remaining text after the final URL
    if (idx < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(idx),
          style: style,
        ),
      );
    }

    /// Render the final formatted text with clickable links
    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}