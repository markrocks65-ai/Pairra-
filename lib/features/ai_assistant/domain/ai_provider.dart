import 'ai_models.dart';

/// The model-agnostic assistant seam. A concrete provider might wrap a hosted
/// LLM (Anthropic, OpenAI, Gemini), an on-device model, or — by default — the
/// local template engine. The app depends only on this interface, so the model
/// can be swapped without touching the UI.
///
/// A provider receives only the pre-sanitized [AiRequest]; it never has access
/// to another user's raw data.
abstract interface class AiProvider {
  /// Human-readable provider name (shown so users know what's answering).
  String get name;

  /// Whether this provider is a real model. The local template engine returns
  /// false so the UI can note that a smarter model can be connected.
  bool get isModelBacked;

  Future<AiResponse> complete(AiRequest request);
}
