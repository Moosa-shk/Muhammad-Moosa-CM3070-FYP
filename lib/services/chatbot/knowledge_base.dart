// lib/services/chatbot/free_knowledge.dart

/// FreeKnowledge provides a small offline knowledge base
/// used by the chatbot. This allows the application to
/// respond to common disaster-related questions even when
/// the user does not have an internet connection.
///
/// The knowledge can be expanded easily by adding more
/// conditions and responses in the future.
class FreeKnowledge {

  /// Returns a basic disaster safety response based on
  /// the user message. If no matching topic is found,
  /// the function returns null.
  static String? answer(String userText) {

    /// Convert text to lowercase for easier keyword matching
    final t = userText.toLowerCase();

    /// Earthquake safety instructions
    if (t.contains("earthquake") || t.contains("zalzala")) {
      return "During an earthquake: Drop, Cover, and Hold On. Stay away from windows, avoid using elevators, and after the shaking stops check gas and electricity connections.";
    }

    /// Flood safety instructions
    if (t.contains("flood") || t.contains("baarish") || t.contains("barish")) {
      return "During a flood: Do not walk or drive through flood water. Move to higher ground and follow official updates. Stay away from electric lines.";
    }

    /// Fire emergency instructions
    if (t.contains("fire") || t.contains("aag")) {
      return "During a fire: Move low under the smoke and use stairs instead of elevators. If your clothes catch fire, remember Stop, Drop, and Roll.";
    }

    /// Emergency kit preparation guidance
    if (t.contains("kit") || t.contains("go bag")) {
      return "An emergency kit should include: water, dry food, torch, power bank, first aid supplies, medicines, copies of ID documents, whistle, mask, cash, and a radio.";
    }

    /// If no matching knowledge topic is found
    return null;
  }
}