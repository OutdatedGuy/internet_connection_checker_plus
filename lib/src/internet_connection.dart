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
/// [http][http_link] package for making network requests.
///
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
  /// Returns the singleton instance of [InternetConnection].
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
    this.customConnectivityCheck,
    this.triggerStream,
    this.useExponentialBackoff = false,
    Duration? backoffInitialDelay,
    Duration backoffMaxDelay = const Duration(seconds: 60),
    double backoffMultiplier = 2.0,
  })  : _checkInterval = checkInterval ?? _defaultCheckInterval,
        _backoffInitialDelayExplicit = backoffInitialDelay != null,
        _backoffInitialDelay =
            _resolveInitialDelay(backoffInitialDelay, checkInterval),
        _backoffMaxDelay = backoffMaxDelay,
        _backoffMultiplier = backoffMultiplier,
        _currentBackoffDelay =
            _resolveInitialDelay(backoffInitialDelay, checkInterval),
        assert(
          useDefaultOptions || customCheckOptions?.isNotEmpty == true,
          'You must provide a list of options if you are not using the '
          'default ones.',
        ) {
    if (useExponentialBackoff) {
      if (backoffMultiplier < 1.0) {
        throw ArgumentError.value(
          backoffMultiplier,
          'backoffMultiplier',
          'Must be >= 1.0 to prevent shrinking intervals.',
        );
      }
      if (backoffMaxDelay <= Duration.zero) {
        throw ArgumentError.value(
          backoffMaxDelay,
          'backoffMaxDelay',
          'Must be greater than zero.',
        );
      }
      if (_backoffInitialDelay <= Duration.zero) {
        throw ArgumentError.value(
          _backoffInitialDelay,
          'backoffInitialDelay',
          'backoffInitialDelay (or checkInterval if implicitly used) must be greater than zero.',
        );
      }
      if (_backoffInitialDelay > _backoffMaxDelay) {
        throw ArgumentError(
          'backoffInitialDelay (or checkInterval if implicitly used) '
          'must be less than or equal to backoffMaxDelay.',
        );
      }
    }
    _internetCheckOptions = List.unmodifiable([
      if (useDefaultOptions) ..._defaultCheckOptions,
      if (customCheckOptions != null) ...customCheckOptions,
    ]);

    _statusController.onListen = () {
      _startListeningToTriggerEvents();
      _maybeEmitStatusUpdate();
    };
    _statusController.onCancel = _handleStatusChangeCancel;
  }

  /// The default check interval duration.
  static const _defaultCheckInterval = Duration(seconds: 10);

  static Duration _resolveInitialDelay(
    Duration? backoffInitialDelay,
    Duration? checkInterval,
  ) =>
      backoffInitialDelay ?? checkInterval ?? _defaultCheckInterval;

  /// The default list of [Uri]s used for checking internet reachability.
  static final _defaultCheckOptions = List<InternetCheckOption>.unmodifiable([
    InternetCheckOption(uri: Uri.parse('https://one.one.one.one')),
    InternetCheckOption(uri: Uri.parse('https://icanhazip.com')),
    InternetCheckOption(
      uri: Uri.parse(
        'https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js',
      ),
    ),
    InternetCheckOption(
      uri: Uri.parse('https://captive.apple.com/internet-check'),
    ),
  ]);

  /// The list of [Uri]s used for checking internet reachability.
  late final List<InternetCheckOption> _internetCheckOptions;

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

  /// Function to check reachability of a single network endpoint.
  ///
  /// This can be customized to allow for different ways of checking
  /// connectivity.
  final ConnectivityCheckCallback? customConnectivityCheck;

  /// An optional stream that triggers an immediate internet connection check
  /// whenever it emits an event.
  final Stream? triggerStream;

  /// Whether exponential backoff is enabled for the polling interval.
  ///
  /// When `true`, the polling interval grows on consecutive failures and resets
  /// to [checkInterval] when the connection is restored.
  ///
  /// Defaults to `false`.
  final bool useExponentialBackoff;

  /// Whether [_backoffInitialDelay] was explicitly provided by the caller.
  ///
  /// When `false`, [_backoffInitialDelay] tracks [_checkInterval] so that
  /// a [setIntervalAndResetTimer] call keeps both values in sync.
  final bool _backoffInitialDelayExplicit;

  /// The initial delay used on the first failure when backoff is enabled.
  ///
  /// Defaults to [checkInterval]. Updated by [setIntervalAndResetTimer] when
  /// no explicit value was provided at construction time.
  Duration _backoffInitialDelay;

  /// The upper bound on the backoff delay.
  ///
  /// Defaults to 60 seconds.
  final Duration _backoffMaxDelay;

  /// The multiplicative factor applied to the delay on each consecutive failure.
  ///
  /// Defaults to 2.0.
  final double _backoffMultiplier;

  /// Whether the backoff state was forcefully reset by an interval change.
  bool _backoffNeedsReset = false;

  /// The live backoff delay, updated each polling cycle when backoff is enabled.
  ///
  /// Resets to [_backoffInitialDelay] on reconnect or subscription cancel.
  Duration _currentBackoffDelay;

  /// The last known internet connection status result.
  InternetStatus? _lastStatus;

  /// The handle for the timer used for periodic status checks.
  Timer? _timerHandle;

  /// Monotonically increasing counter bumped whenever an in-flight
  /// [_maybeEmitStatusUpdate] must be invalidated: on [setIntervalAndResetTimer]
  /// and on [_handleStatusChangeCancel].
  ///
  /// Each [_maybeEmitStatusUpdate] invocation captures this value on entry.
  /// Before mutating shared backoff state or scheduling the next timer it
  /// checks that the value has not changed.  A mismatch means this invocation
  /// is stale — another caller already rescheduled and owns the next cycle.
  int _generation = 0;

  /// Checks if the [Uri] specified in [option] is reachable.
  ///
  /// Returns a [Future] that completes with an [InternetCheckResult] indicating
  /// whether the host is reachable or not.
  Future<InternetCheckResult> _checkReachabilityFor(
    InternetCheckOption option,
  ) async {
    try {
      if (customConnectivityCheck != null) {
        return customConnectivityCheck!.call(option);
      }

      final response = await http
          .head(option.uri, headers: option.headers)
          .timeout(option.timeout);

      return InternetCheckResult(
        option: option,
        isSuccess: option.responseStatusFn(response),
      );
    } catch (_) {
      return InternetCheckResult(
        option: option,
        isSuccess: false,
      );
    }
  }

  /// Updates the interval between connection checks to the given [duration] and
  /// resets the connection checking timer.
  void setIntervalAndResetTimer(Duration duration) {
    _checkInterval = duration;
    if (useExponentialBackoff) {
      // Keep _backoffInitialDelay in sync with the new checkInterval when the
      // caller never provided an explicit backoffInitialDelay.
      if (!_backoffInitialDelayExplicit) _backoffInitialDelay = duration;
      _currentBackoffDelay = _backoffInitialDelay;
      _backoffNeedsReset = true;
    }
    _generation++;
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
  Future<bool> get hasInternetAccess async {
    final completer = Completer<bool>();
    int remainingChecks = _internetCheckOptions.length;
    int successCount = 0;

    for (final option in _internetCheckOptions) {
      unawaited(
        _checkReachabilityFor(option).then((result) {
          if (result.isSuccess) {
            successCount += 1;
          }

          remainingChecks -= 1;

          if (completer.isCompleted) return;

          if (!enableStrictCheck && result.isSuccess) {
            // Return true immediately if not in strict mode and a success is found.
            completer.complete(true);
          } else if (enableStrictCheck && remainingChecks == 0) {
            // In strict mode, complete only when all checks are done.
            completer.complete(successCount == _internetCheckOptions.length);
          } else if (!enableStrictCheck && remainingChecks == 0) {
            // In non-strict mode, complete as false if no success is found.
            completer.complete(false);
          }
        }),
      );
    }

    return completer.future;
  }

  /// Returns the current internet connection status.
  ///
  /// Returns a [Future] that completes with the [InternetStatus] indicating
  /// the current internet connection status.
  Future<InternetStatus> get internetStatus async => await hasInternetAccess
      ? InternetStatus.connected
      : InternetStatus.disconnected;

  /// Internal method for emitting status updates.
  ///
  /// Updates the status and emits it if there are listeners.
  Future<void> _maybeEmitStatusUpdate() async {
    _timerHandle?.cancel();
    final generation = _generation;

    if (!_statusController.hasListener) return;

    // Snapshot before possible mutation below — needed to detect first-failure
    // vs. ongoing-failure for backoff calculation.
    final previousStatus = _lastStatus;

    final currentStatus = await internetStatus;

    if (_lastStatus != currentStatus && _statusController.hasListener) {
      _lastStatus = currentStatus;
      _statusController.add(currentStatus);
    }

    if (!_statusController.hasListener) return;
    // Guard before mutating shared backoff state: a setIntervalAndResetTimer
    // call that arrived while we were awaiting internetStatus has already
    // bumped _generation and scheduled its own timer.  Mutating
    // _currentBackoffDelay / _backoffNeedsReset here would silently overwrite
    // the reset that setIntervalAndResetTimer applied.
    if (_generation != generation) return;

    Duration nextDelay;
    if (useExponentialBackoff) {
      if (currentStatus == InternetStatus.connected) {
        _currentBackoffDelay = _backoffInitialDelay;
        nextDelay = _checkInterval;
      } else if (previousStatus != InternetStatus.disconnected ||
          _backoffNeedsReset) {
        // First failure: previousStatus is either null (first ever poll) or
        // connected — both mean we have not yet been in a backoff streak.
        // Also, if _backoffNeedsReset is true, we treat this as a first failure to
        // reset the backoff delay, even if the previous status was already disconnected.
        _backoffNeedsReset = false;
        _currentBackoffDelay = _backoffInitialDelay > _backoffMaxDelay
            ? _backoffMaxDelay
            : _backoffInitialDelay;
        nextDelay = _currentBackoffDelay;
      } else {
        // Ongoing failure: grow the delay.
        final ms =
            (_currentBackoffDelay.inMilliseconds * _backoffMultiplier).round();
        _currentBackoffDelay = Duration(
          milliseconds: ms.clamp(0, _backoffMaxDelay.inMilliseconds).toInt(),
        );
        nextDelay = _currentBackoffDelay;
      }
    } else {
      nextDelay = _checkInterval;
    }

    _timerHandle = Timer(nextDelay, _maybeEmitStatusUpdate);
  }

  /// Handles cancellation of status change events.
  ///
  /// Cancels the timer and resets the last status.
  void _handleStatusChangeCancel() {
    _triggerSubscription?.cancel();
    _triggerSubscription = null;
    _generation++;
    _timerHandle?.cancel();
    _timerHandle = null;
    _lastStatus = null;
    _backoffNeedsReset = false;
    if (useExponentialBackoff) _currentBackoffDelay = _backoffInitialDelay;
  }

  /// The result of the last attempt to check the internet status.
  InternetStatus? get lastTryResults => _lastStatus;

  /// Stream that emits internet connection status changes.
  Stream<InternetStatus> get onStatusChange async* {
    if (_lastStatus != null) {
      yield _lastStatus!;
    }
    yield* _statusController.stream;
  }

  /// Connectivity subscription.
  StreamSubscription? _triggerSubscription;

  /// Starts listening to trigger events from [triggerStream].
  void _startListeningToTriggerEvents() {
    if (_triggerSubscription != null) return;
    if (triggerStream == null) return;

    _triggerSubscription = triggerStream!.listen(
      (_) => _maybeEmitStatusUpdate(),
      onError: (_, __) {},
    );
  }
}
