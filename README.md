# Internet Connection Checker Plus

A Flutter package to check your internet connection with subsecond response
times, even on mobile networks!

[![pub package][package_svg]][package] [![GitHub][license_svg]](LICENSE)

[![GitHub issues][issues_svg]][issues]
[![GitHub issues closed][issues_closed_svg]][issues_closed]

<hr />

This library provides functionality to monitor and verify internet connectivity
by checking reachability to various URIs. It relies on the `connectivity_plus`
package for listening to connectivity changes and the `http` package for making
network requests.

## Features

- ✅ Check internet connectivity status
- ✅ Listen to internet connectivity changes
- ✅ Customizable endpoints and success criteria

## Supported Platforms

|      Features      | Android | iOS | macOS | Linux | Windows | Web |
| :----------------: | :-----: | :-: | :---: | :---: | :-----: | :-: |
| Check Connectivity |   ✅    | ✅  |  ✅   |  ✅   |   ✅    | ✅  |
| Listen to Changes  |   ✅    | ✅  |  ✅   |  ✅   |   ✅    | ✅  |

## Permissions

### Android

Add the following permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### macOS

Add the following to your macOS `.entitlements` files:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

For more information, see the [Flutter Networking Documentation].

## Usage

### Checking for internet connectivity (one-time)

The simplest way to check if you have internet access:

```dart
final bool isConnected = await InternetConnection().hasInternetAccess;
if (isConnected) {
  print('Connected!');
} else {
  print('No internet connection.');
}
```

### Listening to internet connectivity changes

The `InternetConnection` class exposes a stream of `InternetStatus` updates,
allowing you to react to changes in connectivity:

```dart
final subscription = InternetConnection().onStatusChange.listen(
  (InternetStatus status) {
    if (status == InternetStatus.connected) {
      // Internet is connected
    } else {
      // Internet is disconnected
    }
  },
);
```

> [!NOTE]
>
> Don't forget to cancel the subscription when it is no longer needed. This will
> prevent memory leaks and free up resources:
>
> ```dart
> @override
> void dispose() {
>   subscription.cancel();
>   super.dispose();
> }
> ```

### Using custom endpoints (URIs)

You can specify your own endpoints to check for connectivity:

```dart
final connection = InternetConnection.createInstance(
  customCheckOptions: [
    InternetCheckOption(uri: Uri.parse('https://example.com')),
  ],
);
final isConnected = await connection.hasInternetAccess;
```

> [!IMPORTANT]
>
> - Make sure the endpoints have no caching enabled.
> - On `web` platform, make sure the endpoints are not CORS blocked.

### Using custom success criteria

You can define what counts as a successful response:

```dart
final connection = InternetConnection.createInstance(
  customCheckOptions: [
    InternetCheckOption(
      uri: Uri.parse('https://example.com'),
      responseStatusFn: (response) {
        return response.statusCode >= 69 && response.statusCode < 169;
      },
    ),
    InternetCheckOption(
      uri: Uri.parse('https://example2.com'),
      responseStatusFn: (response) => response.statusCode == 420,
    ),
  ],
);
final isConnected = await connection.hasInternetAccess;
```

### Using a custom connectivity check method

For advanced use cases, you can completely customize how connectivity checks are performed by providing your own connectivity checker:

```dart
final connection = InternetConnection.createInstance(
  customConnectivityCheck: (option) async {
    // Example: Use the Dio http client
    try {
      final dio = Dio();
      final response = await dio.head(
        option.uri,
        options: Options(headers: option.headers, receiveTimeout: option.timeout, validateStatus: (_) => true),
      );

      return InternetCheckResult(
        option: option,
        isSuccess: response.statusCode == 200,
      );
    } catch (_) {
      return InternetCheckResult(option: option, isSuccess: false);
    }
  },
);
```

This customization gives you full control over the connectivity detection process, allowing you to:

- Implement platform-specific network detection
- Use alternate connectivity checking strategies
- Implement custom fallback mechanisms
- Add detailed logging or metrics for connectivity checks
- Integrate with other network monitoring tools

### Pause and Resume on App Lifecycle Changes

For situation where you want to pause any network requests when the app goes
into the background and resume them when the app comes back into the foreground
(see [issue #27]):

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final StreamSubscription<InternetStatus> _subscription;
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      // Handle internet status changes
    });
    _listener = AppLifecycleListener(
      onResume: _subscription.resume,
      onHide: _subscription.pause,
      onPause: _subscription.pause,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build your widget
  }
}
```

### 8. Using `enableStrictCheck`

The `enableStrictCheck` option can be used to require that **all** checked URIs
must respond successfully for the internet to be considered available. By
default, only one successful response is required.

```dart
final connection = InternetConnection.createInstance(
  enableStrictCheck: true,
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

## Built-in and Additional URIs

### Default URIs

The following endpoints are checked by default:

| URI                                          | Description                                                |
| :------------------------------------------- | :--------------------------------------------------------- |
| https://one.one.one.one                      | Response time is less than `100ms`, CORS enabled, no-cache |
| https://icanhazip.com                        | Response time is less than `100ms`, CORS enabled, no-cache |
| https://jsonplaceholder.typicode.com/todos/1 | Response time is less than `100ms`, CORS enabled, no-cache |
| https://pokeapi.co/api/v2/ability/?limit=1   | Response time is less than `100ms`, CORS enabled, no-cache |

### More Tested URIs

The following URIs are tested and work well with the package:

| URI                                        | Description                              |
| :----------------------------------------- | :--------------------------------------- |
| https://ipapi.co/ip                        | CORS enabled, no-cache                   |
| https://api.adviceslip.com/advice          | CORS enabled, no-cache                   |
| https://api.bitbucket.org/2.0/repositories | CORS enabled, no-cache                   |
| https://api.thecatapi.com/v1/images/search | CORS enabled, no-cache                   |
| https://randomuser.me/api/?inc=gender      | CORS enabled, no-cache                   |
| https://dog.ceo/api/breed/husky/list       | CORS enabled, no-cache                   |
| https://lenta.ru                           | Russia supported, CORS enabled, no-cache |
| https://www.gazeta.ru                      | Russia supported, CORS enabled, no-cache |

## If you liked the package, then please give it a [Like 👍🏼][package] and [Star ⭐][repository]

## Credits

This package is a cloned and modified version of the
[internet_connection_checker] package, which itself was based on
[data_connection_checker] (now unmaintained).

The main goal of this package is to provide a more reliable and faster solution
for checking internet connectivity in Flutter applications.

<!-- Badges URLs -->

[package_svg]: https://img.shields.io/pub/v/internet_connection_checker_plus.svg?color=blueviolet
[license_svg]: https://img.shields.io/github/license/OutdatedGuy/internet_connection_checker_plus.svg?color=purple
[issues_svg]: https://img.shields.io/github/issues/OutdatedGuy/internet_connection_checker_plus.svg
[issues_closed_svg]: https://img.shields.io/github/issues-closed/OutdatedGuy/internet_connection_checker_plus.svg?color=green

<!-- Links -->

[Flutter Networking Documentation]: https://docs.flutter.dev/data-and-backend/networking
[package]: https://pub.dev/packages/internet_connection_checker_plus
[repository]: https://github.com/OutdatedGuy/internet_connection_checker_plus
[issues]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues
[issues_closed]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues?q=is%3Aissue+is%3Aclosed
[internet_connection_checker]: https://github.com/RounakTadvi/internet_connection_checker
[data_connection_checker]: https://pub.dev/packages/data_connection_checker
[issue #27]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues/27
