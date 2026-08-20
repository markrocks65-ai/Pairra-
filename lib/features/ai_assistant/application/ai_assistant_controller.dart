import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/onboarding_profile.dart';
import '../../places/places.dart';
import '../../profile/application/profile_providers.dart';
import '../data/local_ai_provider.dart';
import '../domain/ai_models.dart';
import '../domain/ai_provider.dart';
import '../domain/ai_task.dart';

/// One exchange: the user's prompt and the assistant's response (null while
/// loading).
@immutable
class AiTurn {
  const AiTurn({required this.prompt, this.response});
  final String prompt;
  final AiResponse? response;
  bool get loading => response == null;
}

@immutable
class AiAssistantState {
  const AiAssistantState({this.turns = const [], this.busy = false});
  final List<AiTurn> turns;
  final bool busy;

  AiAssistantState copyWith({List<AiTurn>? turns, bool? busy}) =>
      AiAssistantState(turns: turns ?? this.turns, busy: busy ?? this.busy);
}

/// Drives the AI assistant. It builds a privacy-safe [AiRequest] for each task
/// (pulling real venue data through [PlacesService] for date tasks, and only
/// the user's OWN profile signals otherwise), then delegates to the swappable
/// [AiProvider]. No other user's private data ever enters a request.
class AiAssistantController extends StateNotifier<AiAssistantState> {
  AiAssistantController(this._provider, this._places, this._self)
      : super(const AiAssistantState());

  final AiProvider _provider;
  final PlacesService _places;
  final OnboardingProfile _self;

  Future<void> run(AiTask task, {String? userText}) async {
    final prompt = _promptFor(task, userText);
    state = state.copyWith(
      turns: [...state.turns, AiTurn(prompt: prompt)],
      busy: true,
    );

    final request = await _buildRequest(task, userText);
    final response = await _provider.complete(request);

    if (!mounted) return;
    final turns = [...state.turns];
    turns[turns.length - 1] = AiTurn(prompt: prompt, response: response);
    state = state.copyWith(turns: turns, busy: false);
  }

  String _promptFor(AiTask task, String? userText) {
    if (task == AiTask.messageDrafting &&
        (userText ?? '').trim().isNotEmpty) {
      return 'Reply ideas for: "${userText!.trim()}"';
    }
    return task.label;
  }

  Future<AiRequest> _buildRequest(AiTask task, String? userText) async {
    switch (task) {
      case AiTask.dateIdeas:
      case AiTask.datePlanning:
      case AiTask.firstDateSuggestions:
        final venues =
            await _places.search(const PlacesQuery(maxDistanceKm: 25));
        return AiRequest(
          task: task,
          venueLines: [
            for (final v in venues.take(4))
              '${v.name} · ${v.category.label} · ${v.price.estimateLabel} for two',
          ],
        );
      case AiTask.profileImprovement:
        return AiRequest(task: task, profileHints: {
          'photos': _self.photos.length,
          'bioLength': (_self.bio ?? '').trim().length,
          'interests': _self.interests.length,
          'intentions': _self.datingIntentions.length,
        });
      case AiTask.messageDrafting:
        return AiRequest(task: task, userText: userText);
      case AiTask.conversationStarters:
      case AiTask.relationshipCommunication:
      case AiTask.compatibilityExplanation:
        return AiRequest(task: task);
    }
  }
}

final aiProviderProvider = Provider<AiProvider>((ref) => const LocalAiProvider());

final aiAssistantControllerProvider =
    StateNotifierProvider<AiAssistantController, AiAssistantState>((ref) {
  return AiAssistantController(
    ref.watch(aiProviderProvider),
    ref.watch(placesServiceProvider),
    ref.watch(currentProfileProvider),
  );
});
