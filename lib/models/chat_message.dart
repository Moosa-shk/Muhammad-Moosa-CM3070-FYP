// lib/models/chat_message.dart
import 'package:flutter/widgets.dart';

/// Represents a single chat message in the chatbot conversation.
enum ChatRole { user, bot }

class ChatMessage {
  final ChatRole role;

  // Optional plain text message
  final String? text;

  // Optional custom widget content (rich UI bubble)
  final Widget? child;

  ChatMessage({
    required this.role,
    this.text,
    this.child,
  });
}