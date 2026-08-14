// lib/services/chatbot/intent_router.dart

/// Enum representing the different types of chatbot intents.
/// These intents help the chatbot understand what the user is
/// asking for and route the request to the appropriate feature.
enum BotIntent {
  alerts,
  nearbyHospital,
  nearbyShelter,
  nearbyPolice,
  nearbyFire,
  sos,
  general,
}

/// IntentRouter is responsible for detecting the user's intent
/// based on the text entered in the chatbot. The router analyzes
/// keywords in the message and maps them to the corresponding
/// system feature such as alerts, SOS, or nearby services.
class IntentRouter {

  /// Detects the user's intent from the input text
  BotIntent detect(String text) {

    /// Normalize the input for easier keyword matching
    final t = text.toLowerCase().trim();

    /// Helper function that checks if any keyword exists in the message
    bool has(List<String> keys) => keys.any((k) => t.contains(k));

    /// Detect SOS or emergency related requests
    if (has(["sos", "help", "emergency", "sms", "whatsapp", "call"])) {
      return BotIntent.sos;
    }

    /// Detect disaster alerts or warnings
    if (has(["alert", "alerts", "warning", "disaster", "earthquake", "flood"])) {
      return BotIntent.alerts;
    }

    /// Detect request for nearby hospital or medical help
    if (has(["hospital", "doctor", "clinic"])) return BotIntent.nearbyHospital;

    /// Detect request for shelters or relief camps
    if (has(["shelter", "relief", "camp"])) return BotIntent.nearbyShelter;

    /// Detect police related queries
    if (has(["police"])) return BotIntent.nearbyPolice;

    /// Detect fire emergency related queries
    if (has(["fire", "firebrigade"])) return BotIntent.nearbyFire;

    /// Default case for general conversation
    return BotIntent.general;
  }
}