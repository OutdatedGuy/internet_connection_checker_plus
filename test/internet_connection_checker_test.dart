import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('internet_connection_checker_plus', () {
    StreamSubscription<InternetConnectionStatus>? listener1;
    StreamSubscription<InternetConnectionStatus>? listener2;

    tearDown(() {
      // destroy any active listener after each test
      listener1?.cancel();
      listener2?.cancel();
    });

    test('''Shouldn't have any listeners attached''', () {
      expect(
        InternetConnectionCheckerPlus().hasListeners,
        isFalse,
      );
    });

    test('''Unawaited call hasConnection should return a Future<bool>''', () {
      expect(
        InternetConnectionCheckerPlus().hasConnection,
        isA<Future<bool>>(),
      );
    });

    test('''Awaited call to hasConnection should return a bool''', () async {
      expect(
        await InternetConnectionCheckerPlus().hasConnection,
        isA<bool>(),
      );
    });

    test(
        '''Unawaited call to connectionStatus '''
        '''should return a Future<InternetConnectionStatus>''', () {
      expect(
        InternetConnectionCheckerPlus().connectionStatus,
        isA<Future<InternetConnectionStatus>>(),
      );
    });

    test(
        '''Awaited call to connectionStatus '''
        '''should return a Future<InternetConnectionStatus>''', () async {
      expect(
        await InternetConnectionCheckerPlus().connectionStatus,
        isA<InternetConnectionStatus>(),
      );
    });

    test('''We shouldn't have any listeners 1''', () {
      expect(
        InternetConnectionCheckerPlus().hasListeners,
        isFalse,
      );
    });

    test('''We should have listeners 1''', () {
      listener1 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      expect(
        InternetConnectionCheckerPlus().hasListeners,
        isTrue,
      );
    });

    test('''We should have listeners 2''', () {
      listener1 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      listener2 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      expect(
        InternetConnectionCheckerPlus().hasListeners,
        isTrue,
      );
    });

    test('''We should have listeners 3''', () async {
      listener1 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      await listener1!.cancel();
      listener2 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      expect(
        InternetConnectionCheckerPlus().hasListeners,
        isTrue,
      );
    });

    test('''We shouldn't have any listeners 2''', () async {
      listener1 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      await listener1!.cancel();
      listener2 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      await listener2!.cancel();
      expect(
        InternetConnectionCheckerPlus().hasListeners,
        isFalse,
      );
    });

    test('''We shouldn't have any listeners 1''', () {
      expect(
        InternetConnectionCheckerPlus().hasListeners,
        isFalse,
      );
    });

    test('''We should have listeners 1 [isActivelyChecking]''', () {
      listener1 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      expect(
        InternetConnectionCheckerPlus().isActivelyChecking,
        isTrue,
      );
    });

    test('''We should have listeners 2 [isActivelyChecking]''', () {
      listener1 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      listener2 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      expect(
        InternetConnectionCheckerPlus().isActivelyChecking,
        isTrue,
      );
    });

    test('''We should have listeners 3 [isActivelyChecking]''', () async {
      listener1 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      await listener1!.cancel();
      listener2 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      expect(
        InternetConnectionCheckerPlus().isActivelyChecking,
        isTrue,
      );
    });

    test('''We shouldn't have any listeners 2 [isActivelyChecking]''',
        () async {
      listener1 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      await listener1!.cancel();
      listener2 = InternetConnectionCheckerPlus().onStatusChange.listen((_) {});
      await listener2!.cancel();
      expect(
        InternetConnectionCheckerPlus().isActivelyChecking,
        isFalse,
      );
    });

    test('''We should be able to set a custom timeout value''', () async {
      const Duration timeout = Duration(seconds: 1);
      final InternetConnectionCheckerPlus internetConnectionCheckerPlus =
          InternetConnectionCheckerPlus.createInstance(
        checkTimeout: timeout,
      );
      expect(
        internetConnectionCheckerPlus.addresses.every(
          (AddressCheckOptions element) => element.timeout == timeout,
        ),
        isTrue,
      );
    });

    test('''We should be able to set a custom interval value''', () async {
      const Duration interval = Duration(seconds: 1);
      final InternetConnectionCheckerPlus internetConnectionCheckerPlus =
          InternetConnectionCheckerPlus.createInstance(
        checkInterval: interval,
      );
      expect(
        internetConnectionCheckerPlus.checkInterval,
        interval,
      );
    });

    test('''We should be able to set a custom timeout value''', () async {
      const Duration timeout = Duration(seconds: 1);
      final InternetConnectionCheckerPlus internetConnectionCheckerPlus =
          InternetConnectionCheckerPlus.createInstance(
        checkTimeout: timeout,
      );
      expect(
        internetConnectionCheckerPlus.checkTimeout,
        timeout,
      );
      expect(
        internetConnectionCheckerPlus.addresses.every(
          (AddressCheckOptions element) => element.timeout == timeout,
        ),
        isTrue,
      );
    });

    test('''We should be able to set custom addresses''', () async {
      final List<AddressCheckOptions> addresses = <AddressCheckOptions>[
        InternetConnectionCheckerPlus.defaultAddresses.first,
      ];
      final InternetConnectionCheckerPlus internetConnectionCheckerPlus =
          InternetConnectionCheckerPlus.createInstance(
        addresses: addresses,
      );
      expect(
        internetConnectionCheckerPlus.addresses,
        addresses,
      );
    });
  });
}
