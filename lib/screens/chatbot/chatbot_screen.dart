// ===============================================================
// chatbot_screen.dart
// ---------------------------------------------------------------
// This screen provides a conversational interface where users
// can interact with the DisasterAid chatbot.
//
// The chatbot allows users to quickly request emergency
// information such as:
//
// • Disaster alerts
// • Nearest hospital
// • Nearest shelter
// • Police near the user
// • SOS help guidance
//
// Messages are displayed in a chat interface where user
// messages appear on one side and bot responses on the other.
//
// The ChatbotService processes the user's message and returns
// a response which is then displayed in the chat UI.
// ===============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../models/chat_message.dart';
import '../../services/chatbot_service.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/text_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {

  /// Controller for message input field
  final _controller = TextEditingController();

  /// Controller for scrolling chat messages
  final _scroll = ScrollController();

  /// Chatbot service instance
  late final ChatbotService bot;

  /// List of chat messages displayed in the UI
  final messages = <ChatMessage>[

    /// Initial greeting message from the chatbot
   ChatMessage(
  role: ChatRole.bot,
  text:
      "Hello! I am the DisasterAid bot.\n"
      "You can ask me things like 'alerts', 'nearest hospital', "
      "'nearest shelter', 'police near me', or 'SOS help'.",
),
  ];

  /// Indicates whether a message is currently being sent
  bool sending = false;

  // ===============================================================
  // INIT STATE
  // ---------------------------------------------------------------
  // Initializes the chatbot service when the screen loads.
  // ===============================================================

  @override
  void initState() {
    super.initState();
    bot = ChatbotService();
  }

  // ===============================================================
  // DISPOSE
  // ---------------------------------------------------------------
  // Disposes controllers to prevent memory leaks when the
  // widget is removed from the widget tree.
  // ===============================================================

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ===============================================================
  // SCROLL DOWN
  // ---------------------------------------------------------------
  // Automatically scrolls the chat list to the newest message
  // whenever a new message is added.
  // ===============================================================

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 160,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  // ===============================================================
  // SEND MESSAGE
  // ---------------------------------------------------------------
  // Handles sending a user message to the chatbot service and
  // displaying the response returned by the bot.
  // ===============================================================

  Future<void> _send() async {

    final text = _controller.text.trim();

    /// Prevent sending empty messages or multiple requests
    if (text.isEmpty || sending) return;

    setState(() {
      sending = true;

      /// Add user message to chat
      messages.add(ChatMessage(role: ChatRole.user, text: text));

      _controller.clear();
    });

    _scrollDown();

    /// Get response from chatbot service
    final replyMsg = await bot.reply(text);

    setState(() {

      /// Add bot response to chat
      messages.add(replyMsg);

      sending = false;
    });

    _scrollDown();
  }

  // ===============================================================
  // BUILD METHOD
  // ---------------------------------------------------------------
  // Main UI layout consisting of:
  // 1. App bar
  // 2. Chat messages list
  // 3. Input field for sending messages
  // ===============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bg,

      // ============================
      // APP BAR
      // ============================

      appBar: AppBar(
        backgroundColor: AppColor.bg,
        elevation: 0,
        centerTitle: true,

        title: const TextWidget(
          "DisasterAid Chatbot",
          weight: FontWeight.w900,
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.secondary),
          onPressed: () => Get.back(),
        ),

        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
          ),
        ],
      ),

      // ============================
      // BODY
      // ============================

      body: Column(
        children: [

          /// Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              itemCount: messages.length,

              /// Each message displayed using ChatBubble widget
              itemBuilder: (_, i) => ChatBubble(msg: messages[i]),
            ),
          ),

          /// Message input bar
          _inputBar(),
        ],
      ),
    );
  }

  // ===============================================================
  // INPUT BAR
  // ---------------------------------------------------------------
  // Bottom section where users can type a message and send it
  // to the chatbot.
  // ===============================================================

  Widget _inputBar() {

    return SafeArea(
      top: false,

      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),

          /// Top border separating chat from input field
          border: Border(
            top: BorderSide(color: AppColor.border),
          ),
        ),

        child: Row(
          children: [

            // ============================
            // TEXT INPUT FIELD
            // ============================

            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,

                /// Send message when user presses Enter
                onSubmitted: (_) => _send(),

                cursorColor: AppColor.primary,

                decoration: InputDecoration(
                  hintText:
                      "Type: alerts / nearest hospital / police near me ...",

                  hintStyle: TextStyle(
                    color: AppColor.textMuted.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),

                  filled: true,
                  fillColor: AppColor.inputFill,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.border),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.border),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.primary),
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ============================
            // SEND BUTTON
            // ============================

            GestureDetector(
              onTap: sending ? null : _send,

              child: Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  color: sending
                      ? Colors.grey.shade300
                      : AppColor.primary,

                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                /// Show loading indicator while waiting for bot reply
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}