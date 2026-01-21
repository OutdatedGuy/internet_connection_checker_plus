part of '../internet_connection_checker_plus.dart';

/// A callback function for checking if a specific internet endpoint is
/// reachable.
///
/// Takes a single [InternetCheckOption] and returns a
/// [Future] that completes with an [InternetCheckResult].
///
/// This allows for complete customization of how connectivity is checked for
/// each endpoint.
typedef ConnectivityCheckCallback = Future<InternetCheckResult> Function(
  InternetCheckOption option,
);

/// A utility class for checking internet connectivity status.
///
/// This class provides functionality to monitor and verify internet
/// connectivity by checking reachability to various [Uri]s. It relies on the
/// [connectivity_plus] package for listening to connectivity changes and the
/// [http][http_link] package for making network requests.
///
/// [connectivity_plus]: https://pub.dev/packages/connectivity_plus
/// [http_link]: https://pub.dev/packages/http
///
/// <br />
///
/// ## Usage
///
/// <hr />
///
/// ### Checking for internet connectivity
///
/// ```dart
/// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
///
/// bool result = await InternetConnection().hasInternetAccess;
/// ```
///
/// <br />
///
/// ### Listening for internet connectivity changes
///
/// ```dart
/// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
///
/// final listener = InternetConnection().onStatusChange.listen(
///   (InternetStatus status) {
///     switch (status) {
///       case InternetStatus.connected:
///         // The internet is now connected
///         break;
///       case InternetStatus.disconnected:
///         // The internet is now disconnected
///         break;
///     }
///   },
/// );
/// ```
///
/// Don't forget to cancel the subscription when it is no longer needed. This
/// will prevent memory leaks and free up resources.
///
/// ```dart
/// listener.cancel();
/// ```
class InternetConnection {
  /// Returns an instance of [InternetConnection].
  ///
  /// This is a singleton class, meaning that there is only one instance of it.
  factory InternetConnection() => _instance;

  /// Creates an instance of [InternetConnection].
  ///
  /// The [checkInterval] defines the interval duration between status checks.
  ///
  /// The [customCheckOptions] specify the list of [Uri]s to check for
  /// connectivity.
  ///
  /// The [useDefaultOptions] flag indicates whether to use the default [Uri]s.
  /// - If [useDefaultOptions] is `true` (default), the default [Uri]s will be
  /// used along with any [customCheckOptions] provided.
  ///
  /// - If [useDefaultOptions] is `false`, you must provide a non-empty
  /// [customCheckOptions] list.
  ///
  /// The [customConnectivityCheck] allows you to provide a custom method for
  /// checking endpoint reachability. If provided, it will be used for all
  /// connectivity checks instead of the default HTTP HEAD request
  /// implementation.
  InternetConnection.createInstance({
    Duration? checkInterval,
    List<InternetCheckOption>? customCheckOptions,
    bool useDefaultOptions = true,
    this.enableStrictCheck = false,
    this.slowConnectionConfig,
    this.customConnectivityCheck,
  })  : _checkInterval = checkInterval ?? _defaultCheckInterval,
        assert(
          useDefaultOptions || customCheckOptions?.isNotEmpty == true,
          'You must provide a list of options if you are not using the '
          'default ones.',
        ) {
    _internetCheckOptions = [
      if (useDefaultOptions) ..._defaultCheckOptions,
      if (customCheckOptions != null) ...customCheckOptions,
    ];

    _statusController.onListen = _maybeEmitStatusUpdate;
    _statusController.onCancel = _handleStatusChangeCancel;
  }

  /// The default check interval duration.
  static const _defaultCheckInterval = Duration(seconds: 10);

  /// The default list of [Uri]s used for checking internet reachability.
  final List<InternetCheckOption> _defaultCheckOptions = [
    InternetCheckOption(uri: Uri.parse('https://one.one.one.one')),
    InternetCheckOption(uri: Uri.parse('https://icanhazip.com/')),
    InternetCheckOption(
      uri: Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
    ),
    InternetCheckOption(
      uri: Uri.parse('https://pokeapi.co/api/v2/ability/?limit=1'),
    ),
  ];

  /// The list of [Uri]s used for checking internet reachability.
  late List<InternetCheckOption> _internetCheckOptions;

  /// The controller for the internet connection status stream.
  final _statusController = StreamController<InternetStatus>.broadcast();

  /// The singleton instance of [InternetConnection].
  static final _instance = InternetConnection.createInstance();

  /// The duration between consecutive status checks.
  ///
  /// Defaults to [_defaultCheckInterval].
  Duration _checkInterval;

  /// If `true`, all checks must be successful to consider the internet as
  /// connected.
  ///
  /// If `false`, only one successful check is required to consider the internet
  /// as connected.
  ///
  /// Defaults to `false`.
  ///
  /// **Important:** Use this feature only with custom-defined Uris, not with
  /// the default ones, to avoid potential issues with reliability or service
  /// outages.
  final bool enableStrictCheck;

  final SlowConnectionConfig? slowConnectionConfig;

  /// Function to check reachability of a single network endpoint.
  ///
  /// This can be customized to allow for different ways of checking
  /// connectivity.
  final ConnectivityCheckCallback? customConnectivityCheck;

  /// The last known internet connection status result.
  InternetStatus? _lastStatus;

  /// The handle for the timer used for periodic status checks.
  Timer? _timerHandle;

  /// Connectivity subscription.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Checks if the [Uri] specified in [option] is reachable.
  ///
  /// Returns a [Future] that completes with an [InternetCheckResult] indicating
  /// whether the host is reachable or not.
  Future<InternetCheckResult> _checkReachabilityFor(InternetCheckOption option) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (customConnectivityCheck != null) return customConnectivityCheck!(option);

      final response = await http.head(option.uri, headers: option.headers).timeout(option.timeout);
      final responseTime = stopwatch.elapsed;
      stopwatch.stop();

      return InternetCheckResult(
        option: option,
        isSuccess: option.responseStatusFn(response),
        responseTime: responseTime,
      );
    } catch (_) {
      stopwatch.stop();

      return InternetCheckResult(
        option: option,
        isSuccess: false,
        responseTime: stopwatch.elapsed,
      );
    }
  }

  /// Updates the interval between connection checks to the given [duration] and
  /// resets the connection checking timer.
  void setIntervalAndResetTimer(Duration duration) {
    _checkInterval = duration;
    _timerHandle?.cancel();
    _timerHandle = Timer(_checkInterval, _maybeEmitStatusUpdate);
  }

  /// Returns the current duration between connection checks.
  Duration get checkInterval => _checkInterval;

  /// Checks if there is internet access by verifying connectivity to the
  /// specified [Uri]s.
  ///
  /// Returns a [Future] that completes with a boolean value indicating
  /// whether internet access is available or not.
  /// Checks if there is internet access by verifying connectivity to the
  /// specified [Uri]s.
  Future<bool> get hasInternetAccess =>
      enableStrictCheck ? _hasInternetAccessStrict() : _hasInternetAccessNonStrict();

  /// Checks internet access in strict mode (all endpoints must succeed)
  Future<bool> _hasInternetAccessStrict() async {
    final results = await Future.wait(_internetCheckOptions.map(_checkReachabilityFor));

    return results.every((result) => result.isSuccess);
  }

  /// Checks internet access in non-strict mode (at least one endpoint must succeed)
  Future<bool> _hasInternetAccessNonStrict() async {
    final futures = _internetCheckOptions.map(_checkReachabilityFor);

    for (final future in futures) {
      try {
        final result = await future;
        if (result.isSuccess) return true;
      } catch (_) {
        // Continue checking other endpoints
        continue;
      }
    }

    return false;
  }

  /// Returns the current internet connection status.
  ///
  /// Returns a [Future] that completes with the [InternetStatus] indicating
  /// the current internet connection status.
  /// Returns the current internet connection status.
  Future<InternetStatus> get internetStatus async {
    if (slowConnectionConfig == null) {
      // No slow connection detection - use simple boolean check
      return await hasInternetAccess ? InternetStatus.connected : InternetStatus.disconnected;
    }
    final slowConnectionThreshold = slowConnectionConfig!.slowConnectionThreshold;

    return enableStrictCheck
        ? await _internetStatusWithSlowDetectionStrict(
            slowConnectionThreshold: slowConnectionThreshold)
        : await _internetStatusWithSlowDetectionNonStrict(
            slowConnectionThreshold: slowConnectionThreshold);
  }

  /// Determines internet status with slow detection in strict mode
  Future<InternetStatus> _internetStatusWithSlowDetectionStrict({
    required Duration slowConnectionThreshold,
  }) async {
    final results = await Future.wait(_internetCheckOptions.map(_checkReachabilityFor));

    // Check if all endpoints succeeded
    final allSucceeded = results.every((result) => result.isSuccess);
    if (!allSucceeded) return InternetStatus.disconnected;

    // Check for slow connection
    final anySlow = results.any(
        (result) => result.responseTime != null && result.responseTime! > slowConnectionThreshold);

    return anySlow ? InternetStatus.slow : InternetStatus.connected;
  }

  /// Determines internet status with slow detection in non-strict mode
  Future<InternetStatus> _internetStatusWithSlowDetectionNonStrict({
    required Duration slowConnectionThreshold,
  }) async {
    final futures = _internetCheckOptions.map(_checkReachabilityFor);

    bool foundFastConnection = false;
    bool foundAnyConnection = false;

    for (final future in futures) {
      try {
        final result = await future;
        if (result.isSuccess) {
          foundAnyConnection = true;

          // Check if this connection is fast
          if (result.responseTime != null && result.responseTime! <= slowConnectionThreshold) {
            foundFastConnection = true;
          }
        }
      } catch (_) {
        continue;
      }

      // Early return: if we found a fast connection, return connected immediately
      if (foundFastConnection) return InternetStatus.connected;
    }

    // We found connections but they were all slow
    if (foundAnyConnection) return InternetStatus.slow;

    return InternetStatus.disconnected;
  }

  /// Internal method for emitting status updates.
  ///
  /// Updates the status and emits it if there are listeners.
  Future<void> _maybeEmitStatusUpdate() async {
    if (!_statusController.hasListener) return;

    _startListeningToConnectivityChanges();
    _timerHandle?.cancel();

    final currentStatus = await internetStatus;
    if (_lastStatus != currentStatus) _statusController.add(currentStatus);

    _timerHandle = Timer(_checkInterval, _maybeEmitStatusUpdate);
    _lastStatus = currentStatus;
  }

  /// Handles cancellation of status change events.
  ///
  /// Cancels the timer and resets the last status.
  void _handleStatusChangeCancel() {
    if (_statusController.hasListener) return;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _timerHandle?.cancel();
    _timerHandle = null;
    _lastStatus = null;
  }

  /// The result of the last attempt to check the internet status.
  InternetStatus? get lastTryResults => _lastStatus;

  /// Stream that emits internet connection status changes.
  Stream<InternetStatus> get onStatusChange => _statusController.stream;

  /// Starts listening to connectivity changes from [connectivity_plus] package
  /// using the [Connectivity.onConnectivityChanged] stream.
  ///
  /// [connectivity_plus]: https://pub.dev/packages/connectivity_plus
  void _startListeningToConnectivityChanges() {
    if (_connectivitySubscription != null) return;

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (_) {
        if (_statusController.hasListener) _maybeEmitStatusUpdate();
      },
      onError: (_, __) {},
    );
  }
}
