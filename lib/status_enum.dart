part of internet_connection_checker_plus;

/// Represents the status of the data connection.
/// Returned by [InternetConnectionCheckerPlus.connectionStatus]
enum InternetConnectionStatus {
  /// connected to internet
  connected,

  /// disconnected from internet
  disconnected,
}
