part of '../internet_connection_checker_plus.dart';

/// Enum representing the status of internet connectivity.
///
/// This enum defines two possible values to represent the status of internet
/// connectivity: `connected` and `disconnected`.
///
/// *Usage Example:*
///
/// ```dart
/// if (status == InternetStatus.connected) {
///   print('Internet is available!');
/// } else {
///   print('No internet connection.');
/// }
/// ```
enum InternetStatus {
  /// Internet is available because at least one of the HEAD requests succeeded.
  connected,

  /// None of the HEAD requests succeeded. Basically, no internet.
  disconnected,
}
