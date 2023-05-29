part of internet_connection_checker_plus;

/// Options for checking the internet connectivity to an address.
///
/// This class provides a way to specify options for checking the connectivity
/// of an address. It includes the URI to check and the timeout duration for
/// the HEAD request.
///
/// Usage example:
/// ```dart
/// final options = InternetCheckOption(
///   uri: Uri.parse('https://example.com'),
///   timeout: Duration(seconds: 5),
/// );
/// ```
class InternetCheckOption {
  /// Creates an [InternetCheckOption] instance.
  ///
  /// Options for checking the internet connectivity to an address.
  ///
  /// This class provides a way to specify options for checking the connectivity
  /// of an address. It includes the URI to check and the timeout duration for
  /// the HEAD request.
  ///
  /// Usage example:
  /// ```dart
  /// final options = InternetCheckOption(
  ///   uri: Uri.parse('https://example.com'),
  ///   timeout: Duration(seconds: 5),
  /// );
  /// ```
  InternetCheckOption({
    required this.uri,
    this.timeout = const Duration(seconds: 3),
  });

  /// URI to check for connectivity. A HEAD request will be made to this URI.
  ///
  /// Make sure that the cache-control header is set to `no-cache` on the server
  /// side. Otherwise, the HEAD request will be cached and the result will be
  /// incorrect.
  ///
  /// For `web` platform, make sure that the URI is _CORS_ enabled. To check if
  /// requests are being blocked, open the **Network tab** in your browser's
  /// developer tools and see if the request is being blocked by _CORS_.
  final Uri uri;

  /// The duration after the HEAD request should be timed out.
  ///
  /// Defaults to 3 seconds.
  final Duration timeout;

  @override
  String toString() {
    return 'InternetCheckOption(\n'
        '  uri: $uri,\n'
        '  timeout: $timeout\n'
        ')';
  }
}
