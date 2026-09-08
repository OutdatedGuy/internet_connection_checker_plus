part of '../internet_connection_checker_plus.dart';

/// Configuration for exponential backoff of the polling interval used by
/// [InternetConnection.onStatusChange].
///
/// Pass an instance to [InternetConnection.createInstance]'s `backoffOptions`
/// parameter to enable it. When omitted (`null`), the polling interval stays
/// fixed at [InternetConnection.checkInterval], preserving the existing
/// behaviour exactly.
///
/// *Usage Example:*
///
/// ```dart
/// final checker = InternetConnection.createInstance(
///   backoffOptions: ExponentialBackoffOptions(
///     maxDelay: Duration(seconds: 60),
///     multiplier: 2.0,
///   ),
/// );
/// ```
@immutable
class ExponentialBackoffOptions {
  /// Creates an [ExponentialBackoffOptions] instance.
  ///
  /// The [initialDelay] is the delay applied after the first detected
  /// failure. If omitted, it tracks
  /// [InternetConnection.checkInterval] instead, including through
  /// [InternetConnection.setIntervalAndResetTimer] calls.
  ///
  /// The [maxDelay] caps how large the delay may grow. Defaults to 60
  /// seconds.
  ///
  /// The [multiplier] is the factor applied to the delay on each consecutive
  /// failure. Defaults to `2.0`.
  ExponentialBackoffOptions({
    this.initialDelay,
    this.maxDelay = const Duration(seconds: 60),
    this.multiplier = 2.0,
  })  : assert(
          multiplier.isFinite && multiplier >= 1.0,
          'multiplier must be a finite number >= 1.0, to prevent shrinking '
          'or invalid intervals.',
        ),
        assert(maxDelay > Duration.zero, 'maxDelay must be greater than zero.'),
        assert(
          initialDelay == null || initialDelay > Duration.zero,
          'initialDelay must be greater than zero.',
        ),
        assert(
          initialDelay == null || initialDelay <= maxDelay,
          'initialDelay must be less than or equal to maxDelay.',
        );

  /// The delay applied after the first detected failure.
  ///
  /// If `null`, tracks [InternetConnection.checkInterval] instead.
  final Duration? initialDelay;

  /// The upper bound on the backoff delay.
  ///
  /// Defaults to 60 seconds.
  final Duration maxDelay;

  /// The factor applied to the delay on each consecutive failure.
  ///
  /// Defaults to `2.0`.
  final double multiplier;

  /// Resolves the delay to use on the first failure, falling back to
  /// [checkInterval] when [initialDelay] was not provided.
  Duration resolveInitialDelay(Duration checkInterval) {
    final delay = initialDelay ?? checkInterval;
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Computes the delay to use before the next poll.
  ///
  /// Pass [isFirstFailure] as `true` for the first failure in a new streak
  /// (i.e. the previous poll succeeded, or backoff was just reset), and
  /// `false` for an ongoing failure streak, in which case [current] is grown
  /// by [multiplier] and capped at [maxDelay].
  Duration nextDelay({
    required Duration current,
    required bool isFirstFailure,
    required Duration checkInterval,
  }) {
    if (isFirstFailure) return resolveInitialDelay(checkInterval);

    final grownMs = (current.inMilliseconds * multiplier).round();
    return Duration(
      milliseconds: grownMs.clamp(0, maxDelay.inMilliseconds).toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExponentialBackoffOptions &&
          runtimeType == other.runtimeType &&
          initialDelay == other.initialDelay &&
          maxDelay == other.maxDelay &&
          multiplier == other.multiplier;

  @override
  int get hashCode => Object.hash(initialDelay, maxDelay, multiplier);

  @override
  String toString() => 'ExponentialBackoffOptions(\n'
      '  initialDelay: $initialDelay,\n'
      '  maxDelay: $maxDelay,\n'
      '  multiplier: $multiplier\n'
      ')';
}
