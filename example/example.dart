import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Future<void> main() async {
  // Check internet connection with singleton (no custom values allowed)
  await execute(InternetConnectionCheckerPlus());

  // Create customized instance which can be registered via dependency injection
  final InternetConnectionCheckerPlus customInstance =
      InternetConnectionCheckerPlus.createInstance(
    checkTimeout: const Duration(seconds: 1),
    checkInterval: const Duration(seconds: 1),
  );

  // Check internet connection with created instance
  await execute(customInstance);
}

Future<void> execute(
  InternetConnectionCheckerPlus internetConnectionCheckerPlus,
) async {
  // Simple check to see if we have Internet
  // ignore: avoid_print
  print('''The statement 'this machine is connected to the Internet' is: ''');
  final bool isConnected = await InternetConnectionCheckerPlus().hasConnection;
  // ignore: avoid_print
  print(
    isConnected.toString(),
  );
  // returns a bool

  // We can also get an enum instead of a bool
  // ignore: avoid_print
  print(
    'Current status: ${await InternetConnectionCheckerPlus().connectionStatus}',
  );
  // Prints either InternetConnectionStatus.connected
  // or InternetConnectionStatus.disconnected

  // actively listen for status updates
  final StreamSubscription<InternetConnectionStatus> listener =
      InternetConnectionCheckerPlus().onStatusChange.listen(
    (InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          // ignore: avoid_print
          print('Data connection is available.');
          break;
        case InternetConnectionStatus.disconnected:
          // ignore: avoid_print
          print('You are disconnected from the internet.');
          break;
      }
    },
  );

  // close listener after 30 seconds, so the program doesn't run forever
  await Future<void>.delayed(const Duration(seconds: 30));
  await listener.cancel();
}
