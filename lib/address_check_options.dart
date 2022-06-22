part of internet_connection_checker_plus;

/// This class should be pretty self-explanatory.
/// If [AddressCheckOptions.port]
/// or [AddressCheckOptions.timeout] are not specified, they both
/// default to [InternetConnectionCheckerPlus.defaultPort]
/// and [InternetConnectionCheckerPlus.defaultTimeout]
/// Also... yeah, I'm not great at naming things.
class AddressCheckOptions {
  /// [AddressCheckOptions] Constructor
  AddressCheckOptions(
    this.address, {
    this.port = InternetConnectionCheckerPlus.defaultPort,
    this.timeout = InternetConnectionCheckerPlus.defaultTimeout,
  });

  /// An internet address or a Unix domain address.
  /// This object holds an internet address. If this internet address
  /// is the result of a DNS lookup, the address also holds the hostname
  /// used to make the lookup.
  /// An Internet address combined with a port number represents an
  /// endpoint to which a socket can connect or a listening socket can
  /// bind.
  final InternetAddress address;

  /// Port
  final int port;

  /// Timeout Duration
  final Duration timeout;

  @override
  String toString() => 'AddressCheckOptions($address, $port, $timeout)';
}
