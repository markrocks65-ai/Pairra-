import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../discovery/application/matches_controller.dart';
import 'messaging_controller.dart';

/// The messaging store. Seeds conversations from current matches and keeps them
/// in sync as new matches arrive (without dropping typed messages).
final messagingControllerProvider =
    StateNotifierProvider<MessagingController, MessagingState>((ref) {
  final controller = MessagingController();
  controller.syncMatches(ref.read(matchesControllerProvider));
  ref.listen(
    matchesControllerProvider,
    (_, next) => controller.syncMatches(next),
  );
  return controller;
});
