part of '../internet_connection_checker_plus.dart';

/// Configuration options for detecting slow internet connections.
///
/// The [SlowConnectionConfig] class allows you to specify settings for detecting slow internet connections.
/// This includes whether to enable slow connection detection and the threshold duration that defines a "slow" connection.
/// *Example Usage:*
/// ```dart
/// final config = SlowConnectionConfig(slowConnectionThreshold: Duration(seconds: 5));
/// ```
class SlowConnectionConfig {
  /// The threshold duration that defines a "slow" connection.
  ///
  /// A connection is considered slow if the response time
  /// exceeds this duration.
  final Duration slowConnectionThreshold;

  /// Creates an instance of `SlowConnectionConfig`.
  /// The [slowConnectionThreshold] parameter defines the threshold duration
  ///
  /// *Example:*
  /// ```dart
  /// final config = SlowConnectionConfig(slowConnectionThreshold: Duration(seconds: 5));
  /// ```
  const SlowConnectionConfig({required this.slowConnectionThreshold});
}
