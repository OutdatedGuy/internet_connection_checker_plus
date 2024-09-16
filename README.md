# Internet Connection Checker Plus

A Flutter package to check your internet connection with subsecond response
times, even on mobile networks!

[![pub package][package_svg]][package]
[![GitHub][license_svg]](LICENSE)

[![GitHub issues][issues_svg]][issues]
[![GitHub issues closed][issues_closed_svg]][issues_closed]

<hr />

This library provides functionality to monitor and verify internet connectivity
by checking reachability to various `Uri`s. It relies on the `connectivity_plus`
package for listening to connectivity changes and the `http` package for making
network requests.

## Features

- Check internet connectivity status
- Listen for internet connectivity changes

## Supported Platforms

| Platform | Check Connectivity | Listen for Changes |
| :------: | :----------------: | :----------------: |
| Android  |         ✅         |         ✅         |
|   iOS    |         ✅         |         ✅         |
|  macOS   |         ✅         |         ✅         |
|  Linux   |         ✅         |         ✅         |
| Windows  |         ✅         |         ✅         |
|   Web    |         ✅         |         ✅         |

## Permissions

### Android

Add the following permissions to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### macOS

Add the following permissions to your macOS `.entitlements` files:

```entitlements
<key>com.apple.security.network.client</key>
<true/>
```

For more information, see the [Flutter Networking Documentation].

## Usage

### 1. Add dependency

Add the `internet_connection_checker_plus` package to your `pubspec.yaml` file:

```yaml
dependencies:
  internet_connection_checker_plus: ^2.5.1
```

### 2. Import the package

Import the `internet_connection_checker_plus` package into your Dart file:

```dart
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
```

### 3. Checking for internet connectivity

The simplest way to check for internet connectivity is to use the
`InternetConnection` class:

```dart
bool result = await InternetConnection().hasInternetAccess;
```

### 4. Listening for internet connectivity changes

The `InternetConnection` class also provides a stream of `InternetStatus` that
can be used to listen for changes in internet connectivity:

```dart
final listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
  switch (status) {
    case InternetStatus.connected:
      // The internet is now connected
      break;
    case InternetStatus.disconnected:
      // The internet is now disconnected
      break;
  }
});
```

Don't forget to cancel the subscription when it is no longer needed.
This will prevent memory leaks and free up resources:

```dart
listener.cancel();
```

### 5. Add custom `Uri`s to check

The `InternetConnection` class can be configured to check custom `Uri`s for
internet connectivity:

```dart
final connection = InternetConnection.createInstance(
  customCheckOptions: [
    InternetCheckOption(uri: Uri.parse('https://example.com')),
  ],
);
```

> [!IMPORTANT]
>
> Make sure the custom `Uri`s have no caching enabled. Otherwise, the results
> may be inaccurate.

> [!IMPORTANT]
>
> On `web` platform, make sure the custom `Uri`s are not CORS blocked.
> Otherwise, the results may be inaccurate.

### 6. Add custom success criteria

The `InternetConnection` class can be configured to check custom `Uri`s for
internet connectivity using custom success criteria:

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
      responseStatusFn: (response) {
        return response.statusCode >= 420 && response.statusCode < 1412;
      },
    ),
  ],
);
```

### 7. Pause and Resume on App Lifecycle Changes

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

#### Default `Uri`s

The `InternetConnection` class uses the following `Uri`s by default:

| URI                                            | Description                                                |
| :--------------------------------------------- | :--------------------------------------------------------- |
| `https://one.one.one.one`                      | Response time is less than `100ms`, CORS enabled, no-cache |
| `https://icanhazip.com`                        | Response time is less than `100ms`, CORS enabled, no-cache |
| `https://jsonplaceholder.typicode.com/todos/1` | Response time is less than `100ms`, CORS enabled, no-cache |
| `https://reqres.in/api/users/1`                | Response time is less than `100ms`, CORS enabled, no-cache |

#### Some Tested URIs

| URI                                                 | Description                              |
| :-------------------------------------------------- | :--------------------------------------- |
| `https://ipapi.co/ip`                               | CORS enabled, no-cache                   |
| `https://api.adviceslip.com/advice`                 | CORS enabled, no-cache                   |
| `https://api.bitbucket.org/2.0/repositories`        | CORS enabled, no-cache                   |
| `https://api.thecatapi.com/v1/images/search`        | CORS enabled, no-cache                   |
| `https://api.coindesk.com/v1/bpi/currentprice.json` | CORS enabled, no-cache                   |
| `https://lenta.ru`                                  | Russia supported, CORS enabled, no-cache |
| `https://www.gazeta.ru`                             | Russia supported, CORS enabled, no-cache |

### If you liked the package, then please give it a [Like 👍🏼][package] and [Star ⭐][repository]

## Credits

This package is a cloned and modified version of the
[internet_connection_checker] package which is a cloned and modified version of
the [data_connection_checker] package which is no longer maintained.

The aim of this package is to support the `web` platform which is currently not
supported by the [internet_connection_checker] package.

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
