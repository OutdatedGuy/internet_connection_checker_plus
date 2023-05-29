part of internet_connection_checker_plus;

/// Represents the result of an internet connection check.
///
/// This class encapsulates the outcome of an internet connection check
/// performed with a specific [InternetCheckOption].
class InternetCheckResult {
  /// Creates an [InternetCheckResult] instance.
  ///
  /// Represents the result of an internet connection check.
  ///
  /// This class encapsulates the outcome of an internet connection check
  /// performed with a specific [InternetCheckOption].
  InternetCheckResult({
    required this.option,
    required this.isSuccess,
  });

  /// The option used to check internet connection for this result.
  final InternetCheckOption option;

  /// The result of the internet connection check for the given [option].
  ///
  /// If `true`, then HEAD request to the given [option] was successful.
  /// Otherwise, it was unsuccessful.
  final bool isSuccess;

  @override
  String toString() {
    return 'InternetCheckResult(\n'
        '  option: ${option.toString().replaceAll('\n', '\n  ')},\n'
        '  isSuccess: $isSuccess\n'
        ')';
  }
}
