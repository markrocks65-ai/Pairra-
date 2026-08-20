import 'package:flutter/foundation.dart';

/// A single selectable option in PAIRRA's configuration-driven UI. Every list
/// the user picks from (intentions, interests, roles, lifestyle answers…) is a
/// list of these — so options can be added, reordered or localized as data
/// without touching widget code. [id] is the stable value we persist; [label]
/// is what the user sees.
@immutable
class Option {
  const Option(this.id, this.label, {this.description});

  final String id;
  final String label;
  final String? description;

  @override
  bool operator ==(Object other) => other is Option && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
