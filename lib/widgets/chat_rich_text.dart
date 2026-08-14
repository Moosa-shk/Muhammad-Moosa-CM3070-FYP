// lib/widgets/chat_rich_text.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ChatRichText is responsible for displaying chatbot messages
/// while automatically detecting and converting URLs into clickable links.
/// This improves usability by allowing users to directly open reference
/// sources or emergency information links provided by the chatbot.
class ChatRichText extends StatelessWidget {
  const ChatRichText({
    super.key,
    required this.text,
    required this.style,
  });

  /// Text content of the message
  final String text;

  /// Base text style used to render the message
  final TextStyle style;

  /// Regular expression used to detect URLs inside the text
  static final _url = RegExp(r'(https?:\/\/[^\s]+)');

  /// Opens the detected URL using the device's external browser
  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);

    /// If URL parsing fails, do nothing
    if (uri == null) return;

    /// Launch the URL outside the application
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {

    /// Find all URL matches inside the message text
    final matches = _url.allMatches(text).toList();

    /// If no URLs are found, display the text normally
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    /// If URLs are present, build a rich text structure
    final spans = <InlineSpan>[];
    int start = 0;

    /// Loop through detected URL matches
    for (final m in matches) {

      /// Add normal text before the URL
      if (m.start > start) {
        spans.add(TextSpan(text: text.substring(start, m.start)));
      }

      /// Extract the URL from the message
      final url = text.substring(m.start, m.end);

      /// Add clickable URL span
      spans.add(
        TextSpan(
          text: url,

          /// Underline URLs to visually indicate they are clickable
          style: style.copyWith(decoration: TextDecoration.underline),

          /// When tapped, open the URL in the browser
          recognizer: TapGestureRecognizer()..onTap = () => _open(url),
        ),
      );

      /// Update starting position for next text segment
      start = m.end;
    }

    /// Add remaining text after the last URL
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    /// Render the message as RichText with clickable spans
    return RichText(
      text: TextSpan(
        style: style,
        children: spans,
      ),
    );
  }
}