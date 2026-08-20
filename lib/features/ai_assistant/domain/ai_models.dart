import 'package:flutter/foundation.dart';

import 'ai_task.dart';

/// One suggestion the assistant offers. The user chooses whether to use it —
/// suggestions are never sent automatically.
@immutable
class AiSuggestion {
  const AiSuggestion(this.text, {this.copyable = true});
  final String text;

  /// Whether a "copy" affordance makes sense (e.g. a draftable message).
  final bool copyable;
}

/// The assistant's reply: a short framing line plus suggestions.
@immutable
class AiResponse {
  const AiResponse({required this.intro, this.suggestions = const []});
  final String intro;
  final List<AiSuggestion> suggestions;
}

/// A request to the assistant. Carries ONLY privacy-safe, pre-sanitized inputs —
/// the controller extracts these so a provider never receives another user's
/// private data (venues are pre-formatted strings, compatibility is expressed
/// as already-safe reason phrases, etc.).
@immutable
class AiRequest {
  const AiRequest({
    required this.task,
    this.userText,
    this.otherName,
    this.sharedInterests = const {},
    this.venueLines = const [],
    this.profileHints = const {},
    this.compatibilityReasons = const [],
  });

  final AiTask task;

  /// Free-form user input (e.g. a message they want reply ideas for).
  final String? userText;

  /// First name only, when relevant. Never more identifying than that.
  final String? otherName;

  /// Interests both people share (safe — both have them public).
  final Set<String> sharedInterests;

  /// Pre-formatted, public venue summaries for date tasks.
  final List<String> venueLines;

  /// Non-sensitive counts about the user's OWN profile (photos, bio length…).
  final Map<String, int> profileHints;

  /// Already-privacy-safe reason phrases (bands, never roles).
  final List<String> compatibilityReasons;
}
