import 'package:flutter/foundation.dart';

import 'sequence_segment.dart';

/// A named list of exercises that the user plays in order, as one
/// session.
@immutable
class ExerciseSequence {
  const ExerciseSequence({
    required this.id,
    required this.name,
    this.segments = const [],
  });

  static const maxSegments = 12;
  static const maxNameLength = 40;

  /// Identifies the sequence in the store. It does not change when the
  /// user renames the sequence.
  final String id;
  final String name;
  final List<SequenceSegment> segments;

  bool get canAddSegment => segments.length < maxSegments;
  bool get hasClearance => segments.any((s) => s is ClearanceSegment);

  /// The name, or a placeholder when the user left it empty.
  String get displayName =>
      name.trim().isEmpty ? 'Untitled sequence' : name.trim();

  /// The segments in one line, for example "Box × 6 · Huffs with rests".
  String get summary => segments.isEmpty
      ? 'No parts yet'
      : segments.map((s) => s.label).join(' · ');

  ExerciseSequence copyWith({String? name, List<SequenceSegment>? segments}) =>
      ExerciseSequence(
        id: id,
        name: name ?? this.name,
        segments: segments ?? this.segments,
      );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'segments': [for (final segment in segments) segment.toJson()],
  };

  /// Reads a sequence that [toJson] wrote. Returns null when the data
  /// has no id. Unknown segments are left out.
  static ExerciseSequence? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    if (id is! String) return null;
    final name = json['name'];
    final segments = json['segments'];
    return ExerciseSequence(
      id: id,
      name: name is String ? name : '',
      segments: [
        if (segments is List)
          for (final segment in segments.map(SequenceSegment.fromJson))
            ?segment,
      ].take(maxSegments).toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ExerciseSequence &&
      other.id == id &&
      other.name == name &&
      listEquals(other.segments, segments);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(segments));
}
