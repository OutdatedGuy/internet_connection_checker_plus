> - NOTE: This package is a continuation of [internet_connection_checker](https://github.com/RounakTadvi/internet_connection_checker) which currently is not supported for web. \*

# 🌍 Internet Connection Checker Plus

[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Pure Dart Utility library that checks for an Active Internet connection by opening a socket to a list of specified addresses, each with individual port and timeout. Defaults are provided for convenience.

> _Note that this plugin is in beta and may still have
> a few issues. [Feedback][issues_tracker] is welcome._

### Table of contents

- [🌍 Internet Connection Checker Plus](#🌍-internet-connection-checker-plus)
  - [Table of contents](#table-of-contents)
  - [Description](#description)
  - [Quick start](#quick-start)
  - [Purpose](#purpose)
  - [How it works](#how-it-works)
  - [Defaults](#defaults)
    - [`defaultAddresses`](#default_addresses)
    - [`defaultPort`](#default_port)
    - [`defaultTimeout`](#default_timeout)
    - [`defaultInterval`](#default_interval)
  - [Usage](#usage)
    - [Singleton example](#singleton-example)
    - [Create instance example](#create-instance-example)
  - [Features and bugs](#features-and-bugs)

## Description

Checks for an internet (data) connection, by opening a socket to a list of addresses.

The defaults of the plugin should be sufficient to reliably determine if
the device is currently connected to the global network, e.i. has access to the Internet.

> Note that you should not be using the current network status for deciding whether you can reliably make a network connection. Always guard your app code against timeouts and errors that might come from the network layer.

## Quick start

#### Add to Dependencies

```yaml
internet_connection_checker_plus: ^1.0.1
```

#### Import the package

```dart
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
```

`InternetConnectionCheckerPlus()` is actually a Singleton. Calling `InternetConnectionCheckerPlus()`
is guaranteed to always return the same instance.

You can supply a new list to `InternetConnectionCheckerPlus().addresses` if you
need to check different destinations, ports and timeouts.
Also, each address can have its own port and timeout.
See `InternetAddressCheckOptions` in the docs for more info.

**_First you need to [install it][install] (this is the preferred way)_**

Then you can start using the library:

```dart
bool result = await InternetConnectionCheckerPlus().hasConnection;
if(result == true) {
  print('YAY! Free cute dog pics!');
} else {
  print('No internet :( Reason:');
  print(InternetConnectionCheckerPlus().lastTryResults);
}
```

## Purpose

The reason this package exists is that `connectivity_plus` package cannot reliably determine if a data connection is actually available. More info on its page here: <https://pub.dev/packages/connectivity_plus>

More info on the issue in general:

- <https://stackoverflow.com/questions/1560788/how-to-check-internet-access-on-android-inetaddress-never-times-out/27312494#27312494> (this is the best approach so far IMO and it's what I'm using)

You can use this package in combination with `connectivity_plus` in the following way:

```dart
var isDeviceConnected = false;

var subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
  if(result != ConnectivityResult.none) {
    isDeviceConnected = await InternetConnectionCheckerPlus().hasConnection;
  }
});
```

_Note: remember to properly cancel the `subscription` when it's no longer needed. See `connectivity_plus` package docs for more info._

## How it works

All addresses are pinged simultaneously. On successful result (socket connection to address/port succeeds) a `true` boolean is pushed to a list, on failure (usually on timeout, default 4 sec) a `false` boolean is pushed to the same list.

When all the requests complete with either success or failure, a check is made to see if the list contains at least one `true` boolean. If it does, then an external address is available, so we have data connection. If all the values in this list are `false`, then we have no connection to the outside world of cute cat and dog pictures, so `hasConnection` also returns `false` too.

This all happens at the same time for all addresses, so the maximum waiting time is the address with the highest specified timeout, in case it's unreachable.

I believe this is a **_reliable_** and **_fast_** method to check if a data connection is available to a device, but I may be wrong. I suggest you open an issue on the Github repository page if you have a better way of.

## Defaults

#### `defaultAddresses`

... includes the top 1 globally available free DNS over HTTPS resolver.

| Address | API                                          |
| :------ | :------------------------------------------- |
| 1.1.1.1 | https://cloudflare-dns.com/dns-query         |
| 1.0.0.1 | https://mozilla.cloudflare-dns.com/dns-query |

```dart
static final List<AddressCheckOptions> _defaultAddresses = [
  AddressCheckOptions(
    Uri.parse('https://cloudflare-dns.com/dns-query').replace(
      queryParameters: dnsParameters,
    ),
    headers: dnsHeaders,
  ),
  AddressCheckOptions(
    Uri.parse('https://mozilla.cloudflare-dns.com/dns-query').replace(
      queryParameters: dnsParameters,
    ),
    headers: dnsHeaders,
  ),
];
```

#### `defaultTimeout`

... is 4 seconds.

```dart
static const Duration defaultTimeout = Duration(seconds: 4);
```

#### `defaultInterval`

... is 5 seconds. Interval is the time between automatic checks. Automatic
checks start if there's a listener attached to `onStatusChange`, thus remember
to cancel unneeded subscriptions.

`checkInterval` (which controls how often a check is made) defaults
to this value. You can change it if you need to perform checks more often
or otherwise.

```dart
static const Duration defaultInterval = const Duration(seconds: 5);
...
Duration checkInterval = defaultInterval;
```

## Usage

The `InternetConnectionCheckerPlus` can be used as a singleton or can be instantiated with custom values.

### Singleton example

```dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

main() async {
  // Simple check to see if we have internet
  print("The statement 'this machine is connected to the Internet' is: ");
  print(await InternetConnectionCheckerPlus().hasConnection);
  // returns a bool

  // We can also get an enum value instead of a bool
  print("Current status: ${await InternetConnectionCheckerPlus().connectionStatus}");
  // prints either InternetConnectionStatus.connected
  // or InternetConnectionStatus.disconnected

  // actively listen for status updates
  // this will cause InternetConnectionCheckerPlus to check periodically
  // with the interval specified in InternetConnectionCheckerPlus().checkInterval
  // until listener.cancel() is called
  var listener = InternetConnectionCheckerPlus().onStatusChange.listen((status) {
    switch (status) {
      case InternetConnectionStatus.connected:
        print('Data connection is available.');
        break;
      case InternetConnectionStatus.disconnected:
        print('You are disconnected from the internet.');
        break;
    }
  });

  // close listener after 30 seconds, so the program doesn't run forever
  await Future.delayed(Duration(seconds: 30));
  await listener.cancel();
}
```

_Note: Remember to dispose of any listeners,
when they're not needed to prevent memory leaks,
e.g. in a_ `StatefulWidget`'s _dispose() method_:

```dart
...
@override
void dispose() {
  listener.cancel();
  super.dispose();
}
...
```

See `example` folder for more examples.

### Create instance example

```dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

main() async {
  final customInstance = InternetConnectionCheckerPlus.createInstance(
    checkTimeout: const Duration(seconds: 1), // Custom check timeout
    checkInterval: const Duration(seconds: 1), // Custom check interval
    addresses: [
      ... // Custom addresses
    ],
  );

  // Register it with any dependency injection framework. For example GetIt.
  GetIt.registerSingleton<InternetConnectionCheckerPlus>(
    customInstance,
  );
}
```

_Note: Remember to dispose of any listeners,
when they're not needed to prevent memory leaks,
e.g. in a_ `StatefulWidget`'s _dispose() method_:

```dart
...
@override
void dispose() {
  listener.cancel();
  super.dispose();
}
...
```

See `example` folder for more examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][issues_tracker].

[issues_tracker]: https://github.com/OutdatedGuy/internet_connection_checker_plus/issues
[pull_requests]: https://github.com/OutdatedGuy/internet_connection_checker_plus/pulls
