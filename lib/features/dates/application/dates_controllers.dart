import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../places/places.dart';
import '../domain/planned_date.dart';

/// In-memory store of the user's planned dates (session-scoped; Firestore-ready
/// swap later). Newest first.
class PlannedDatesController extends StateNotifier<List<PlannedDate>> {
  PlannedDatesController() : super(const []);

  void add(PlannedDate date) => state = [date, ...state];

  void remove(String id) =>
      state = state.where((d) => d.id != id).toList();

  List<PlannedDate> get upcoming =>
      state.where((d) => !d.isPast).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<PlannedDate> get past =>
      state.where((d) => d.isPast).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  void clear() => state = const [];
}

/// Saved places (bookmarked venues).
class SavedPlacesController extends StateNotifier<List<Venue>> {
  SavedPlacesController() : super(const []);

  bool isSaved(String id) => state.any((v) => v.id == id);

  void toggle(Venue venue) {
    state = isSaved(venue.id)
        ? state.where((v) => v.id != venue.id).toList()
        : [venue, ...state];
  }

  void clear() => state = const [];
}
