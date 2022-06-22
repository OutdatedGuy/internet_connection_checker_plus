part of internet_connection_checker_plus;

/// Helper class that contains the address options and indicates whether
/// opening a socket to it succeeded.
class AddressCheckResult {
  /// [AddressCheckResult] constructor
  AddressCheckResult(
    this.options, {
    required this.isSuccess,
  });

  /// AddressCheckOptions
  final AddressCheckOptions options;

  /// bool val to store result
  final bool isSuccess;

  @override
  String toString() => 'AddressCheckResult($options, $isSuccess)';
}
