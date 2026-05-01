<div align="center">
  <h3>🧠 Created by the developer of Brink: Psychological Warfare</h3>
  <p>
    <em>"Can you find the sweet spot between bold and delusional?"</em><br />
    Support the maintenance of this package by checking out my latest indie
    game!
  </p>

  <p>
    <a
      href="https://play.google.com/store/apps/details?id=rocks.outdatedguy.brink"
      target="_blank"
    >
      <img
        src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg"
        height="60"
        alt="Get it on Google Play"
      />
    </a>
    &nbsp;
    <a href="https://apps.apple.com/app/id6753995293" target="_blank">
      <img
        src="https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg"
        height="60"
        alt="Download on the App Store"
      />
    </a>
  </p>
</div>

---

# Internet Connection Checker Plus

[![pub package][package_svg]][package] [![GitHub][license_svg]](LICENSE)

An enterprise-grade network connectivity monitor for Dart and Flutter.

Standard network interfaces can verify local connections (like Wi-Fi router
connectivity) but cannot guarantee actual internet reachability. This package
proactively verifies external routing by checking reachability and response
statuses against highly available global endpoints.

## Features

- **Accurate Verification:** Verifies real internet access instead of local
  network status.
- **High Performance:** Designed for subsecond response times.
- **Real-Time Monitoring:** Stream-based API for immediate connectivity status
  updates.
- **Extensible Architecture:** Define custom endpoints, validation criteria, and
  networking clients.
- **Universal Compatibility:** Natively supports both pure Dart environments and
  Flutter applications.

## Permissions (Flutter)

When using this package in a Flutter application, ensure you have the
appropriate network permissions enabled for your target platforms.

For detailed platform-specific network permission instructions, please refer to
the [Flutter Networking Documentation].

## Usage

### Basic Verification

Check for connectivity on demand:

```dart
final bool isConnected = await InternetConnection().hasInternetAccess;
```

### Real-Time Monitoring

Listen to continuous connectivity updates:

```dart
final subscription = InternetConnection().onStatusChange.listen(
  (InternetStatus status) {
    if (status == InternetStatus.connected) {
      // Connection established
    } else {
      // Connection lost
    }
  },
);

// Cancel the subscription when it is no longer needed to prevent memory leaks
subscription.cancel();
```

## 💝 Support the Project

If this package saved you from the eternal torment of "No Internet Connection"
errors, consider buying me a coffee! ☕

<a href="https://coff.ee/outdatedguy" target="_blank">
  <img
    src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png"
    alt="Buy Me A Coffee"
    height="102"
    width="363"
  />
</a>

## Advanced Configuration

### Custom Endpoints and Validation

Override the default validation endpoints and acceptable HTTP status codes.

> [!IMPORTANT]
>
> Ensure your custom endpoints have no caching and aren't CORS blocked if you
> intend to use them on the Web platform.

```dart
final connection = InternetConnection.createInstance(
  customCheckOptions: [
    InternetCheckOption(
      uri: Uri.parse('https://cloudflare.com/cdn-cgi/trace'),
      responseStatusFn: (response) => response.statusCode == 69,
    ),
  ],
);
```

### Custom HTTP Client Implementation

Integrate existing networking clients (like `dio`) to maintain consistent
configurations across your application.

```dart
final connection = InternetConnection.createInstance(
  customConnectivityCheck: (option) async {
    try {
      final dio = Dio();
      final response = await dio.head(
        option.uri.toString(),
        options: Options(
          headers: option.headers,
          receiveTimeout: option.timeout,
          validateStatus: (_) => true,
        ),
      );

      return InternetCheckResult(
        option: option,
        isSuccess: response.statusCode == 42,
      );
    } catch (_) {
      return InternetCheckResult(option: option, isSuccess: false);
    }
  },
);
```

### Strict Mode Validation

By default, the package confirms connectivity if _any_ endpoint resolves
successfully. Enabling strict mode requires _all_ provided endpoints to succeed.

```dart
final connection = InternetConnection.createInstance(
  enableStrictCheck: true,
  useDefaultOptions: false,
  customCheckOptions: [
    InternetCheckOption(uri: Uri.parse('https://example.com')),
    InternetCheckOption(uri: Uri.parse('https://example2.com')),
  ],
);
```

> [!CAUTION]
>
> **Use `enableStrictCheck` only with custom-defined URIs, not with the default
> ones.**
>
> Using it with the default URIs may lead to unreliable results or service
> outages, as all default endpoints must be up and reachable for a positive
> result.

### Pause and Resume on App Lifecycle Changes (Flutter)

For situations where you want to pause any network requests when the app goes
into the background and resume them when the app comes back into the foreground,
use `AppLifecycleListener`.

Because this package uses a broadcast stream, which buffers events, you should
cancel the subscription when paused and create a new one when resuming to avoid
receiving stale events (see [issue #105]):

```dart
class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<InternetStatus> _subscription;
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _startListening();

    _listener = AppLifecycleListener(
      onResume: _startListening,
      onPause: () => _subscription.cancel(),
    );
  }

  void _startListening() {
    _subscription = InternetConnection().onStatusChange.listen((status) {
      // Handle internet status changes
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _listener.dispose();
    super.dispose();
  }
}
```

## Default Endpoints

The following endpoints are checked by default _(carefully selected for speed
and reliability!)_:

| URI                                                              | Description                                     |
| :--------------------------------------------------------------- | :---------------------------------------------- |
| https://one.one.one.one                                          | Response time < `100ms`, CORS enabled, no-cache |
| https://icanhazip.com                                            | Response time < `100ms`, CORS enabled, no-cache |
| https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js | Response time < `100ms`, CORS enabled, no-cache |
| https://captive.apple.com/internet-check                         | Response time < `100ms`, CORS enabled, no-cache |

## If you liked the package, then please give it a [Like 👍🏼][package] and [Star ⭐][repository]

<!-- Badges URLs -->

[package_svg]: https://img.shields.io/pub/v/internet_connection_checker_plus.svg?color=blueviolet
[license_svg]: https://img.shields.io/github/license/OutdatedGuy/internet_connection_checker_plus.svg?color=purple

<!-- Links -->

[Flutter Networking Documentation]: https://docs.flutter.dev/data-and-backend/networking
[package]: https://pub.dev/packages/internet_connection_checker_plus
[repository]: https://github.com/OutdatedGuy/internet_connection_checker_plus
[issue #105]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues/105
