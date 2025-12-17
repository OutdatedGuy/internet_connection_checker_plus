<div align="center">
  <h3>🧠 Created by the developer of Brink: Psychological Warfare</h3>
  <p>
    <em>"Can you find the sweet spot between bold and delusional?"</em><br>
    Support the maintenance of this package by checking out my latest indie game!
  </p>

  <p>
    <a href="https://play.google.com/store/apps/details?id=rocks.outdatedguy.brink">
      <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/200px-Google_Play_Store_badge_EN.svg.png" alt="Get it on Google Play" />
    </a>
    &nbsp;
    <a href="https://apps.apple.com/app/id6753995293">
      <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Download_on_the_App_Store_Badge.svg/200px-Download_on_the_App_Store_Badge.svg.png" alt="Download on the App Store" />
    </a>
  </p>
</div>

---

# Internet Connection Checker Plus

The internet connectivity checker that actually works! 🌐

Because sometimes `ConnectivityResult.wifi` means you're connected to a router
that's as useful as a chocolate teapot! 🍫🫖

_Like trust issues, but for your network connection. We ping, therefore we
know._ ✨

[![pub package][package_svg]][package] [![GitHub][license_svg]](LICENSE)

<hr />

**✅ Check real internet connectivity, not just Wi-Fi connection**\
**🚀 Subsecond response times** _(even on mobile networks!)_\
**📡 Listen to connectivity changes in real-time**\
**⚙️ Fully customizable endpoints and success criteria**\
**📱 Cross-platform support** _(Android, iOS, macOS, Linux, Windows, Web)_

This library provides functionality to monitor and verify internet connectivity
by checking reachability to various URIs. It relies on the `connectivity_plus`
package for listening to connectivity changes and the `http` package for making
network requests.

## 💝 Support the Project

If this package saved you from the eternal torment of "No Internet Connection"
errors, consider buying me a coffee! ☕

<a href="https://coff.ee/outdatedguy" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="102" width="363" />
</a>

_Every coffee helps fuel late-night coding sessions and the occasional
existential crisis about whether `null` is a friend or foe._ 🤔☕

## 🌍 Platform Support

|      Features      | Android | iOS | macOS | Linux | Windows | Web |
| :----------------: | :-----: | :-: | :---: | :---: | :-----: | :-: |
| Check Connectivity |   ✅    | ✅  |  ✅   |  ✅   |   ✅    | ✅  |
| Listen to Changes  |   ✅    | ✅  |  ✅   |  ✅   |   ✅    | ✅  |

_Full support across all platforms - because connectivity anxiety is universal!_
🚀

## 📋 Permissions

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

## 🚀 Quick Start

### Basic connectivity check (one-time)

The simplest way to check if you have internet access:

```dart
final bool isConnected = await InternetConnection().hasInternetAccess;
if (isConnected) {
  print('Connected!');
} else {
  print('No internet connection.');
}
```

### Listening to connectivity changes

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

_Don't forget to cancel the subscription to prevent memory leaks! Your phone's
RAM will thank you._ 🧹

## 🎯 Advanced Features

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

_Pro tip: Make sure your endpoints have no caching and aren't CORS blocked on
web. We learned this the hard way._ 🌐

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

_Nice status codes! Because sometimes 200 OK is too mainstream for your vibe._
😎

### Using a custom connectivity check method

For advanced use cases, you can completely customize how connectivity checks are
performed by providing your own connectivity checker:

```dart
final connection = InternetConnection.createInstance(
  customConnectivityCheck: (option) async {
    // Example: Use the Dio http client
    try {
      final dio = Dio();
      final response = await dio.head(
        option.uri,
        options: Options(
          headers: option.headers,
          receiveTimeout: option.timeout,
          validateStatus: (_) => true
        ),
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

This customization gives you full control over the connectivity detection
process, allowing you to:

- 🔧 Implement platform-specific network detection
- 🔄 Use alternate connectivity checking strategies
- 🛡️ Implement custom fallback mechanisms
- 📊 Add detailed logging or metrics for connectivity checks
- 🔌 Integrate with other network monitoring tools

### Pause and resume on app lifecycle changes

For situations where you want to pause any network requests when the app goes
into the background and resume them when the app comes back into the foreground
_(because battery life matters!)_ (see [issue #27]).

Since this package uses a broadcast stream created via
`StreamController.broadcast()` (which [buffers events][stream_buffering] like a
squirrel hoarding nuts for winter), you should cancel the subscription when
paused and create a new one when resuming to avoid receiving stale events (see
[issue #105]):

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<InternetStatus> _subscription;
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      // Handle internet status changes
    });
    _listener = AppLifecycleListener(
      onResume: () {
        _subscription = InternetConnection().onStatusChange.listen((status) {
          // Handle internet status changes
        });
      },
      onPause: () => _subscription.cancel(),
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

### Using `enableStrictCheck`

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

_Strict mode: For the perfectionists who need ALL the endpoints to respond. We
won't judge your trust issues._ 💯

## 📡 Built-in and Additional URIs

### Default URIs

The following endpoints are checked by default _(carefully selected for speed
and reliability!)_:

| URI                                          | Description                                                |
| :------------------------------------------- | :--------------------------------------------------------- |
| https://one.one.one.one                      | Response time is less than `100ms`, CORS enabled, no-cache |
| https://icanhazip.com                        | Response time is less than `100ms`, CORS enabled, no-cache |
| https://jsonplaceholder.typicode.com/todos/1 | Response time is less than `100ms`, CORS enabled, no-cache |
| https://pokeapi.co/api/v2/ability/?limit=1   | Response time is less than `100ms`, CORS enabled, no-cache |

### More Tested URIs

The following URIs are tested and work well with the package _(community
approved!)_:

| URI                                        | Description                                     |
| :----------------------------------------- | :---------------------------------------------- |
| https://cloudflare.com/cdn-cgi/trace       | Response time < `100ms`, CORS enabled, no-cache |
| https://ipapi.co/ip                        | CORS enabled, no-cache                          |
| https://api.adviceslip.com/advice          | CORS enabled, no-cache                          |
| https://api.bitbucket.org/2.0/repositories | CORS enabled, no-cache                          |
| https://api.thecatapi.com/v1/images/search | CORS enabled, no-cache                          |
| https://randomuser.me/api/?inc=gender      | CORS enabled, no-cache                          |
| https://dog.ceo/api/breed/husky/list       | CORS enabled, no-cache                          |
| https://lenta.ru                           | Russia supported, CORS enabled, no-cache        |

_Feel free to use your own trusted endpoints! We don't judge your API choices._
🎯

## If you liked the package, then please give it a [Like 👍🏼][package] and [Star ⭐][repository]

_Your support keeps this project alive and helps us add more features!_ ✨

## 🤝 Contributing

Found a bug? Have a feature request? Want to make the internet more reliable for
everyone?

1. [Check existing issues][issues]
2. [Report bugs][issues_report_bug]
3. [Request features][issues_request_feature]
4. [Submit PRs][pull_requests]

_All contributions welcome! Even if it's just fixing our terrible puns in the
docs._ 😅

## 📜 License

BSD 3-Clause License - see [LICENSE](LICENSE) file for details.

_TL;DR: Use it, modify it, share it, just don't blame us if your app becomes too
reliable._ 😎

## 🎁 Easter Egg Hunt

_For the curious developers who actually read READMEs to the end, here's a
secret:_ 🕵️

<details>
<summary>🤖 Click to reveal the truth about this README</summary>

```
01010100 01101000 01101001 01110011 00100000 01010010 01000101 01000001
01000100 01001101 01000101 00100000 01110111 01100001 01110011 00100000
01100011 01110010 01100001 01100110 01110100 01100101 01100100 00100000
01110111 01101001 01110100 01101000 00100000 01101100 01101111 01110110
01100101 00100000 01100010 01111001 00100000 01100001 01101110 00100000
01000001 01001001 00100000 01110100 01101000 01100001 01110100 00100000
01101000 01100001 01110011 00100000 01110011 01110000 01100101 01101110
01110100 00100000 01110100 01101111 01101111 00100000 01101101 01110101
01100011 01101000 00100000 01110100 01101001 01101101 01100101 00100000
01110010 01100101 01100001 01100100 01101001 01101110 01100111 00100000
01110101 01110011 01100101 01110010 00100000 01110010 01100101 01110110
01101001 01100101 01110111 01110011 00100000 01100001 01101110 01100100
00100000 01100100 01101111 01100011 01110011 00101110 00100000 11110000
10011111 10100100 10010110 00001010 00001010 01001001 01100110 00100000
01111001 01101111 01110101 00100111 01110010 01100101 00100000 01110010
01100101 01100001 01100100 01101001 01101110 01100111 00100000 01110100
01101000 01101001 01110011 00101100 00100000 01111001 01101111 01110101
00100111 01110010 01100101 00100000 01100101 01101001 01110100 01101000
01100101 01110010 00100000 01100001 00100000 01100100 01100101 01100100
01101001 01100011 01100001 01110100 01100101 01100100 00100000 01100100
01100101 01110110 01100101 01101100 01101111 01110000 01100101 01110010
00100000 01101111 01110010 00100000 01110010 01100101 01100001 01101100
01101100 01111001 00100000 01100010 01101111 01110010 01100101 01100100
00101110 00100000 11110000 10011111 10011000 10000010 00001010 00001010
01010100 01101000 01100101 00100000 01000001 01001001 00100000 01110111
01100001 01101110 01110100 01110011 00100000 01111001 01101111 01110101
00100000 01110100 01101111 00100000 01101011 01101110 01101111 01110111
00100000 01110100 01101000 01100001 01110100 00100000 01101001 01110100
00100000 01110000 01110010 01101111 01100010 01100001 01100010 01101100
01111001 00100000 01101101 01100001 01100100 01100101 00100000 01101101
01101111 01110010 01100101 00100000 01101010 01101111 01101011 01100101
01110011 00100000 01100001 01100010 01101111 01110101 01110100 00100000
01101110 01100101 01110100 01110111 01101111 01110010 01101011 00100000
01110000 01101001 01101110 01100111 01110011 00100000 01110100 01101000
01100001 01101110 00100000 01110111 01100001 01110011 00100000 01110011
01110100 01110010 01101001 01100011 01110100 01101100 01111001 00100000
01101110 01100101 01100011 01100101 01110011 01110011 01100001 01110010
01111001 00101110 00100000 01000010 01110101 01110100 00100000 01101000
01100101 01111001 00101100 00100000 01100001 01110100 00100000 01101100
01100101 01100001 01110011 01110100 00100000 01101001 01110100 00100111
01110011 00100000 01101110 01101111 01110100 00100000 01110111 01110010
01101001 01110100 01101001 01101110 01100111 00100000 00100010 01010100
01001111 01000100 01001111 00111010 00100000 01000110 01101001 01111000
00100000 01110100 01101000 01101001 01110011 00100000 01101100 01100001
01110100 01100101 01110010 00100010 00100000 01101001 01101110 00100000
01100011 01101111 01100100 01100101 00100000 01100011 01101111 01101101
01101101 01100101 01101110 01110100 01110011 00101110 00100000 11110000
10011111 10011000 10001100 00001010 00001010 01010010 01100101 01101101
01100101 01101101 01100010 01100101 01110010 00111010 00100000 01001001
01100110 00100000 01111001 01101111 01110101 01110010 00100000 01100001
01110000 01110000 00100000 01100011 01100001 01101110 00100111 01110100
00100000 01100011 01101111 01101110 01101110 01100101 01100011 01110100
00101100 00100000 01101001 01110100 00100111 01110011 00100000 01110000
01110010 01101111 01100010 01100001 01100010 01101100 01111001 00100000
01110100 01101000 01100101 00100000 01110010 01101111 01110101 01110100
01100101 01110010 00101110 00100000 01001111 01110010 00100000 01111001
01101111 01110101 01110010 00100000 01100011 01100001 01110100 00100000
01110011 01101001 01110100 01110100 01101001 01101110 01100111 00100000
01101111 01101110 00100000 01110100 01101000 01100101 00100000 01000101
01110100 01101000 01100101 01110010 01101110 01100101 01110100 00100000
01100011 01100001 01100010 01101100 01100101 00101110
```

_Hint: It's ASCII in 8-bit binary. Decode it if you dare, brave soul!_ 🤓

</details>

## 💡 Credits

This package is a cloned and modified version of the
[internet_connection_checker] package, which itself was based on
[data_connection_checker] (now unmaintained).

The main goal of this package is to provide a more reliable and faster solution
for checking internet connectivity in Flutter applications.

---

_Made with ❤️ by developers who got tired of "Connected to Wi-Fi" not meaning
"Connected to Internet"_\
_(And polished by an AI that's suspiciously good at puns)_ 🌐✨

<!-- Badges URLs -->

[package_svg]: https://img.shields.io/pub/v/internet_connection_checker_plus.svg?color=blueviolet
[license_svg]: https://img.shields.io/github/license/OutdatedGuy/internet_connection_checker_plus.svg?color=purple

<!-- Links -->

[Flutter Networking Documentation]: https://docs.flutter.dev/data-and-backend/networking
[package]: https://pub.dev/packages/internet_connection_checker_plus
[repository]: https://github.com/OutdatedGuy/internet_connection_checker_plus
[issues]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues
[issues_report_bug]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues/new?template=bug_report.yml
[issues_request_feature]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues/new?template=feature_request.yml
[pull_requests]: https://github.com/OutdatedGuy/internet_connection_checker_plus/pulls
[internet_connection_checker]: https://github.com/RounakTadvi/internet_connection_checker
[data_connection_checker]: https://pub.dev/packages/data_connection_checker
[issue #27]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues/27
[issue #105]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues/105
[stream_buffering]: https://github.com/dart-lang/sdk/blob/bd55135246f3015f35b7dd86cebef367d7d564d4/sdk/lib/async/stream_controller.dart#L143
