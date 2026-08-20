/// What the AI assistant can help with. Each maps to a template in the local
/// provider and a prompt in a future model-backed provider.
enum AiTask {
  conversationStarters('Conversation starters'),
  profileImprovement('Improve my profile'),
  dateIdeas('Date ideas'),
  datePlanning('Plan a date'),
  firstDateSuggestions('First-date ideas'),
  relationshipCommunication('Communication tips'),
  messageDrafting('Help me reply'),
  compatibilityExplanation('Explain a match');

  const AiTask(this.label);
  final String label;
}
