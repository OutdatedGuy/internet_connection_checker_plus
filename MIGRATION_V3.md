# Migration Guide: v2 to v3

This major release removed the dependency on the
[`connectivity_plus`](https://pub.dev/packages/connectivity_plus) package,
converting this library into a pure Dart package. If your application relied on
hardware network connectivity changes to quickly trigger internet reachability
checks, you must now pass a trigger stream explicitly.

## Breaking Changes

- Automatic listening to network hardware changes (e.g. Wi-Fi turning off) is no
  longer enabled by default since we no longer depend on `connectivity_plus`.

## Migration Steps

If you want to maintain the exact same behavior from `v2.x.x`, follow these
steps:

### 1. Add `connectivity_plus` to your pubspec.yaml

Since it is no longer bundled with our package, you must install it directly.

```yaml
dependencies:
  internet_connection_checker_plus: ^3.0.0
  connectivity_plus: ^7.0.0 # or latest
```

### 2. Pass the trigger stream to `InternetConnection`

When you create or configure the internet connection, use the `createInstance`
method and pass `Connectivity().onConnectivityChanged` to the new
`triggerStream` parameter.

**Before (v2):**

```dart
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final connection = InternetConnection();
```

**After (v3):**

```dart
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connection = InternetConnection.createInstance(
  triggerStream: Connectivity().onConnectivityChanged,
);
```

By providing a `triggerStream`, `InternetConnection` will instantly execute a
ping reachability check whenever `connectivity_plus` emits an event, ensuring
your users get the most accurate and real-time connectivity status.
