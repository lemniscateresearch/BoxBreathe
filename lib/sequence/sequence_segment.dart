import '../breathing/breathing_method.dart';
import '../clearance/clearance_routine.dart';
import '../common/int_range.dart';

/// One part of an [ExerciseSequence]: a breathing shape for a number of
/// breaths, or an airway clearance routine.
///
/// The class is sealed, so a `switch` on a segment must handle every
/// kind, and the compiler checks this.
sealed class SequenceSegment {
  const SequenceSegment();

  /// The name of the exercise, for example "Box breathing".
  String get title;

  /// A short name for the segment, for example "Box × 6".
  String get label;

  Map<String, Object?> toJson();

  /// Reads a segment that [toJson] wrote. Returns null for unknown or
  /// incorrect data, so that one bad segment does not lose the others.
  static SequenceSegment? fromJson(Object? json) {
    if (json is! Map) return null;
    T? byName<T extends Enum>(List<T> values) =>
        values.where((value) => value.name == json['name']).firstOrNull;

    switch (json['kind']) {
      case 'breathing':
        final method = byName(BreathingMethod.values);
        final breaths = json['breaths'];
        if (method == null || breaths is! int) return null;
        return BreathingSegment(
          method,
          breaths: BreathingSegment.breathsRange.clamp(breaths),
        );
      case 'clearance':
        final routine = byName(ClearanceRoutine.values);
        return routine == null ? null : ClearanceSegment(routine);
      default:
        return null;
    }
  }
}

/// A breathing shape, repeated for [breaths] breaths.
final class BreathingSegment extends SequenceSegment {
  const BreathingSegment(this.method, {this.breaths = defaultBreaths});

  static const breathsRange = IntRange(1, 30);
  static const defaultBreaths = 5;

  final BreathingMethod method;
  final int breaths;

  BreathingSegment withBreaths(int breaths) =>
      BreathingSegment(method, breaths: breathsRange.clamp(breaths));

  @override
  String get title => '${method.label} breathing';

  @override
  String get label => '${method.label} × $breaths';

  @override
  Map<String, Object?> toJson() => {
    'kind': 'breathing',
    'name': method.name,
    'breaths': breaths,
  };

  @override
  bool operator ==(Object other) =>
      other is BreathingSegment &&
      other.method == method &&
      other.breaths == breaths;

  @override
  int get hashCode => Object.hash(method, breaths);
}

/// An airway clearance routine. It uses the counts and durations from
/// the settings page.
final class ClearanceSegment extends SequenceSegment {
  const ClearanceSegment(this.routine);

  final ClearanceRoutine routine;

  @override
  String get title => routine.label;

  @override
  String get label => routine.label;

  @override
  Map<String, Object?> toJson() => {'kind': 'clearance', 'name': routine.name};

  @override
  bool operator ==(Object other) =>
      other is ClearanceSegment && other.routine == routine;

  @override
  int get hashCode => routine.hashCode;
}
