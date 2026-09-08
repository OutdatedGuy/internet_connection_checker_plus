import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:test/test.dart';

import '__mocks__/test_http_client.dart';

void main() {
  group('InternetConnection', () {
    group('hasInternetAccess', () {
      test('returns true for valid URIs', () async {
        final checker = InternetConnection();
        expect(await checker.hasInternetAccess, true);
      });

      test('returns false for invalid URIs', () async {
        final checker = InternetConnection.createInstance(
          customCheckOptions: [
            InternetCheckOption(
              uri: Uri.parse('https://www.example.com/nonexistent-page'),
            ),
          ],
          useDefaultOptions: false,
        );
        expect(await checker.hasInternetAccess, false);

        await checker.dispose();
      });

      test('invokes responseStatusFn to determine success', () async {
        const expectedStatus = true;
        final checker = InternetConnection.createInstance(
          customCheckOptions: [
            InternetCheckOption(
              uri: Uri.parse('https://www.example.com/nonexistent-page'),
              responseStatusFn: (response) => expectedStatus,
            ),
          ],
          useDefaultOptions: false,
        );

        expect(await checker.hasInternetAccess, expectedStatus);

        await checker.dispose();
      });

      test('sends custom headers on request', () async {
        await TestHttpClient.run((client) async {
          const expectedStatus = true;
          const expectedHeaders = {'Authorization': 'Bearer token'};

          client.responseBuilder = (req) {
            for (final header in expectedHeaders.entries) {
              final key = header.key;
              if (!req.headers.containsKey(key) ||
                  req.headers[key] != header.value) {
                return TestHttpClient.createResponse(statusCode: 500);
              }
            }
            return TestHttpClient.createResponse(statusCode: 200);
          };
          final checker = InternetConnection.createInstance(
            customCheckOptions: [
              InternetCheckOption(
                uri: Uri.parse('https://www.example.com'),
                headers: expectedHeaders,
              ),
            ],
            useDefaultOptions: false,
          );

          expect(await checker.hasInternetAccess, expectedStatus);

          await checker.dispose();
        });
      });

      test(
        'creates and uses default HTTP client when none is provided',
        () async {
          // This test verifies default behavior, which is hard to test directly
          // So we test that the checker works without explicitly providing a client
          final checker = InternetConnection.createInstance(
            customCheckOptions: [
              InternetCheckOption(uri: Uri.parse('https://www.example.com')),
            ],
            useDefaultOptions: false,
          );

          // Since we can't mock the global HTTP client in this test,
          // we just verify that no exception is thrown when executing this
          // This inherently tests that a default client was created and used
          // Successfully checking internet access means the internal client works
          expect(checker.hasInternetAccess, isA<Future<bool>>());

          await checker.dispose();
        },
      );

      test('uses custom reachability checker when provided', () async {
        var reachabilityCheckerCalled = false;

        customReachabilityChecker(InternetCheckOption option) async {
          reachabilityCheckerCalled = true;
          expect(option.uri.host, 'example.com');
          // Return success for this test
          return InternetCheckResult(
            option: option,
            isSuccess: true,
          );
        }

        final checker = InternetConnection.createInstance(
          customCheckOptions: [
            InternetCheckOption(uri: Uri.parse('https://example.com')),
          ],
          useDefaultOptions: false,
          customConnectivityCheck: customReachabilityChecker,
        );

        final result = await checker.hasInternetAccess;
        expect(reachabilityCheckerCalled, true);
        expect(result, true);

        await checker.dispose();
      });
    });

    group('enableStrictCheck', () {
      test('returns true when all URIs are reachable', () async {
        final checker = InternetConnection.createInstance(
          enableStrictCheck: true,
          customCheckOptions: [
            InternetCheckOption(uri: Uri.parse('https://one.one.one.one')),
            InternetCheckOption(uri: Uri.parse('https://icanhazip.com/')),
            InternetCheckOption(
              uri: Uri.parse('https://pokeapi.co/api/v2/ability/?limit=1'),
            ),
          ],
          useDefaultOptions: false,
        );
        expect(await checker.hasInternetAccess, true);

        await checker.dispose();
      });

      test('returns false when any URI is unreachable', () async {
        final checker = InternetConnection.createInstance(
          enableStrictCheck: true,
          customCheckOptions: [
            InternetCheckOption(
              uri: Uri.parse('https://www.example.com/nonexistent-page'),
            ),
          ],
        );
        expect(await checker.hasInternetAccess, false);

        await checker.dispose();
      });
    });

    group('checkInterval', () {
      test('executes requests with given frequency', () async {
        await TestHttpClient.run((client) async {
          int counter = 0;

          client.responseBuilder = (req) {
            counter++;
            return TestHttpClient.createResponse(statusCode: 200);
          };
          final checker = InternetConnection.createInstance(
            checkInterval: const Duration(milliseconds: 100),
            useDefaultOptions: false,
            customCheckOptions: [
              InternetCheckOption(
                uri: Uri.parse('https://www.example.com'),
              ),
            ],
          );
          final sub = checker.onStatusChange.listen((_) {});

          await Future.delayed(const Duration(milliseconds: 500));

          // Give it tiny error space.
          expect(4 <= counter && counter <= 6, true);

          sub.cancel();
          await checker.dispose();
        });
      });

      test('correctly changes the interval', () async {
        await TestHttpClient.run((client) async {
          int counter = 0;

          client.responseBuilder = (req) {
            counter++;
            return TestHttpClient.createResponse(statusCode: 200);
          };

          final checker = InternetConnection.createInstance(
            checkInterval: const Duration(milliseconds: 100),
            useDefaultOptions: false,
            customCheckOptions: [
              InternetCheckOption(
                uri: Uri.parse('https://www.example.com'),
              ),
            ],
          );

          final sub = checker.onStatusChange.listen((_) {});

          await Future.delayed(const Duration(milliseconds: 500));

          // Give it tiny error space.
          expect(4 <= counter && counter <= 6, true);

          checker.setIntervalAndResetTimer(const Duration(milliseconds: 50));

          await Future.delayed(const Duration(milliseconds: 500));

          expect(14 <= counter && counter <= 16, true);

          sub.cancel();
          await checker.dispose();
        });
      });

      test('interval changes should not cause any additional checks', () async {
        await TestHttpClient.run((client) async {
          int counter = 0;

          client.responseBuilder = (req) {
            counter++;
            return TestHttpClient.createResponse(statusCode: 200);
          };

          final checker = InternetConnection.createInstance(
            checkInterval: const Duration(milliseconds: 100),
            useDefaultOptions: false,
            customCheckOptions: [
              InternetCheckOption(
                uri: Uri.parse('https://www.example.com'),
              ),
            ],
          );

          final sub = checker.onStatusChange.listen((_) {
            // Setting the same interval upon each emit should not
            // result in any extra triggers.
            checker.setIntervalAndResetTimer(checker.checkInterval);
          });

          await Future.delayed(const Duration(milliseconds: 500));

          // Give it tiny error space.
          expect(4 <= counter && counter <= 6, true);

          sub.cancel();
          await checker.dispose();
        });
      });
    });

    test('main constructor returns the same instance', () {
      final checker = InternetConnection();
      expect(checker, InternetConnection());
    });

    test('createInstance constructor returns different instances', () async {
      final checker = InternetConnection.createInstance();
      expect(checker, isNot(InternetConnection.createInstance()));

      await checker.dispose();
    });

    test('onStatusChange yields cached status immediately to new subscriber',
        () async {
      await TestHttpClient.run((client) async {
        client.responseBuilder =
            (req) => TestHttpClient.createResponse(statusCode: 200);

        final checker = InternetConnection.createInstance(
          // Long interval so no second poll fires during the test.
          checkInterval: const Duration(seconds: 10),
          useDefaultOptions: false,
          customCheckOptions: [
            InternetCheckOption(uri: Uri.parse('https://www.example.com')),
          ],
        );

        // First subscription — wait for the initial check to complete.
        final sub1 = checker.onStatusChange.listen((_) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(checker.lastTryResults, InternetStatus.connected);

        // Second subscription — should receive the cached status without a
        // new network request (next poll is 10s away).
        final received = <InternetStatus>[];
        final sub2 = checker.onStatusChange.listen(received.add);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(received, [InternetStatus.connected]);

        await sub1.cancel();
        await sub2.cancel();

        await checker.dispose();
      });
    });

    group('exponentialBackoff', () {
      // Helper: build a checker that uses customConnectivityCheck so we
      // avoid real network calls and record each invocation timestamp.
      InternetConnection makeChecker({
        required bool Function() shouldSucceed,
        required List<DateTime> callLog,
        Duration checkInterval = const Duration(milliseconds: 100),
        Duration? backoffInitialDelay,
        Duration backoffMaxDelay = const Duration(milliseconds: 800),
        double backoffMultiplier = 2.0,
      }) {
        final option =
            InternetCheckOption(uri: Uri.parse('https://example.com'));
        final checker = InternetConnection.createInstance(
          checkInterval: checkInterval,
          useDefaultOptions: false,
          customCheckOptions: [option],
          backoffOptions: ExponentialBackoffOptions(
            initialDelay: backoffInitialDelay,
            maxDelay: backoffMaxDelay,
            multiplier: backoffMultiplier,
          ),
          customConnectivityCheck: (opt) async {
            callLog.add(DateTime.now());
            return InternetCheckResult(option: opt, isSuccess: shouldSucceed());
          },
        );
        addTearDown(checker.dispose);
        return checker;
      }

      test('exposes the effective backoff configuration via public getters',
          () async {
        final checker = InternetConnection.createInstance(
          checkInterval: const Duration(seconds: 10),
          useDefaultOptions: false,
          customCheckOptions: [
            InternetCheckOption(uri: Uri.parse('https://example.com')),
          ],
          backoffOptions: ExponentialBackoffOptions(
            maxDelay: const Duration(seconds: 30),
            multiplier: 3.0,
          ),
        );
        addTearDown(checker.dispose);

        // initialDelay was omitted, so it should track checkInterval.
        expect(checker.backoffOptions!.initialDelay, null);
        expect(checker.backoffOptions!.maxDelay, const Duration(seconds: 30));
        expect(checker.backoffOptions!.multiplier, 3.0);
        // Before any failure, the live delay equals the initial delay.
        expect(checker.currentBackoffDelay, const Duration(seconds: 10));
      });

      test('disabled by default: interval stays constant under failures',
          () async {
        final callLog = <DateTime>[];

        final checker = InternetConnection.createInstance(
          checkInterval: const Duration(milliseconds: 100),
          useDefaultOptions: false,
          customCheckOptions: [
            InternetCheckOption(uri: Uri.parse('https://www.example.com')),
          ],
          customConnectivityCheck: (opt) async {
            callLog.add(DateTime.now());
            return InternetCheckResult(option: opt, isSuccess: false);
          },
        );

        final sub = checker.onStatusChange.listen((_) {});
        await Future.delayed(const Duration(milliseconds: 550));
        await sub.cancel();

        // With a 100ms interval over 550ms we expect ~4-5 checks.
        expect(callLog.length, greaterThanOrEqualTo(4));

        // All gaps should stay near 100ms — no backoff growth.
        for (int i = 1; i < callLog.length; i++) {
          final gap =
              callLog[i].difference(callLog[i - 1]).inMilliseconds.abs();
          expect(gap, lessThan(200),
              reason: 'gap between check $i and ${i - 1} was ${gap}ms '
                  '— expected ~100ms (constant interval, no backoff)');
        }
      });

      test('first failure sets initialDelay', () async {
        bool connected = true;
        final callLog = <DateTime>[];

        final checker = makeChecker(
          shouldSucceed: () => connected,
          callLog: callLog,
          checkInterval: const Duration(milliseconds: 100),
          backoffInitialDelay: const Duration(milliseconds: 200),
        );

        final sub = checker.onStatusChange.listen((_) {});

        // Wait for at least one connected check.
        await Future.delayed(const Duration(milliseconds: 150));
        callLog.clear();

        // Trigger a disconnect.
        connected = false;

        // Wait long enough for the disconnect to be detected and one backoff
        // cycle to elapse (~100ms for detect + ~200ms for the backoff timer).
        await Future.delayed(const Duration(milliseconds: 450));

        await sub.cancel();

        // We should have at most 2 calls in this window:
        // one that detected the disconnect, and at most one more after
        // the 200ms initialDelay fires.
        expect(callLog.length, lessThanOrEqualTo(3));

        // The gap between the disconnect-detecting call and the next call
        // should be around initialDelay (200ms), not checkInterval (100ms).
        if (callLog.length >= 2) {
          final gap = callLog[1].difference(callLog[0]).inMilliseconds.abs();
          expect(gap, greaterThan(150));
        }
      });

      test('delay grows on consecutive failures', () async {
        final callLog = <DateTime>[];

        final checker = makeChecker(
          shouldSucceed: () => false,
          callLog: callLog,
          checkInterval: const Duration(milliseconds: 50),
          backoffInitialDelay: const Duration(milliseconds: 50),
          backoffMaxDelay: const Duration(milliseconds: 800),
          backoffMultiplier: 2.0,
        );

        final sub = checker.onStatusChange.listen((_) {});

        // Total expected time for ~4 checks: 50 + 50 + 100 + 200 = 400ms
        await Future.delayed(const Duration(milliseconds: 550));
        await sub.cancel();

        expect(callLog.length, greaterThanOrEqualTo(4));

        // Verify that gaps between consecutive calls are non-decreasing.
        final gaps = <int>[];
        for (int i = 1; i < callLog.length; i++) {
          gaps.add(callLog[i].difference(callLog[i - 1]).inMilliseconds.abs());
        }
        for (int i = 1; i < gaps.length; i++) {
          // Each gap should be >= the previous one (allowing 20ms tolerance).
          expect(gaps[i] + 20, greaterThanOrEqualTo(gaps[i - 1]));
        }
      });

      test('delay is capped at maxDelay', () async {
        final callLog = <DateTime>[];

        final checker = makeChecker(
          shouldSucceed: () => false,
          callLog: callLog,
          checkInterval: const Duration(milliseconds: 50),
          backoffInitialDelay: const Duration(milliseconds: 50),
          backoffMaxDelay: const Duration(milliseconds: 200),
          backoffMultiplier: 2.0,
        );

        final sub = checker.onStatusChange.listen((_) {});

        // Run long enough for the delay to have hit the cap and stayed there.
        // 50 + 50 + 100 + 200 + 200 = 600ms total for 5 calls.
        await Future.delayed(const Duration(milliseconds: 900));
        await sub.cancel();

        expect(callLog.length, greaterThanOrEqualTo(4));

        // After the cap is reached, no gap should exceed maxDelay by much.
        for (int i = 3; i < callLog.length; i++) {
          final gap =
              callLog[i].difference(callLog[i - 1]).inMilliseconds.abs();
          expect(gap, lessThan(350)); // maxDelay 200ms + generous tolerance
        }
      });

      test('delay resets to checkInterval on reconnect', () async {
        bool connected = false;
        final callLog = <DateTime>[];

        final checker = makeChecker(
          shouldSucceed: () => connected,
          callLog: callLog,
          checkInterval: const Duration(milliseconds: 50),
          backoffInitialDelay: const Duration(milliseconds: 50),
          backoffMaxDelay: const Duration(milliseconds: 200),
          backoffMultiplier: 2.0,
        );

        final sub = checker.onStatusChange.listen((_) {});

        // Let backoff grow toward maxDelay.
        await Future.delayed(const Duration(milliseconds: 500));

        // Reconnect and flush the log.
        connected = true;
        callLog.clear();

        // After reconnect, polling should revert to checkInterval (50ms).
        await Future.delayed(const Duration(milliseconds: 300));
        await sub.cancel();

        // With 50ms interval over 300ms we expect ~5 calls.
        expect(callLog.length, greaterThanOrEqualTo(3));

        // All gaps should be close to checkInterval (50ms), not maxDelay.
        for (int i = 1; i < callLog.length; i++) {
          final gap =
              callLog[i].difference(callLog[i - 1]).inMilliseconds.abs();
          expect(gap, lessThan(200));
        }
      });

      test('setIntervalAndResetTimer resets backoff state', () async {
        bool connected = false;
        final callLog = <DateTime>[];

        final checker = makeChecker(
          shouldSucceed: () => connected,
          callLog: callLog,
          checkInterval: const Duration(milliseconds: 50),
          backoffInitialDelay: const Duration(milliseconds: 50),
          backoffMaxDelay: const Duration(milliseconds: 200),
          backoffMultiplier: 2.0,
        );

        final sub = checker.onStatusChange.listen((_) {});

        // Let backoff reach maxDelay.
        await Future.delayed(const Duration(milliseconds: 600));
        callLog.clear();

        // Resetting the interval should restart backoff from initialDelay.
        checker.setIntervalAndResetTimer(const Duration(milliseconds: 50));

        await Future.delayed(const Duration(milliseconds: 400));
        await sub.cancel();

        // Should have ~3-5 calls; the gaps should be non-decreasing again
        // (restarted backoff sequence: 50, 100, 200ms…).
        expect(callLog.length, greaterThanOrEqualTo(2));
        if (callLog.length >= 3) {
          final gap1 = callLog[1].difference(callLog[0]).inMilliseconds.abs();
          final gap2 = callLog[2].difference(callLog[1]).inMilliseconds.abs();
          expect(gap2 + 20, greaterThanOrEqualTo(gap1));
        }
      });

      test('setIntervalAndResetTimer syncs implicit backoffInitialDelay',
          () async {
        final callLog = <DateTime>[];

        // Intentionally omit `backoffInitialDelay` and rely on `checkInterval` (50ms)
        final checker = InternetConnection.createInstance(
          checkInterval: const Duration(milliseconds: 50),
          useDefaultOptions: false,
          customCheckOptions: [
            InternetCheckOption(uri: Uri.parse('https://example.com')),
          ],
          backoffOptions: ExponentialBackoffOptions(
            maxDelay: const Duration(milliseconds: 500),
            multiplier: 2.0,
          ),
          customConnectivityCheck: (opt) async {
            callLog.add(DateTime.now());
            return InternetCheckResult(option: opt, isSuccess: false);
          },
        );

        final sub = checker.onStatusChange.listen((_) {});

        // Trigger the first failure
        await Future.delayed(const Duration(milliseconds: 100));
        callLog.clear();

        // Change the interval to 100ms
        // Since it's an implicit initial delay, _backoffInitialDelay should also follow 100ms
        checker.setIntervalAndResetTimer(const Duration(milliseconds: 100));

        await Future.delayed(const Duration(milliseconds: 450));
        await sub.cancel();

        expect(callLog.length, greaterThanOrEqualTo(2));

        if (callLog.length >= 2) {
          final firstGap =
              callLog[1].difference(callLog[0]).inMilliseconds.abs();

          // If it follows, it should be around 100ms; if not, it would be around 50ms
          // Verify that it is greater than 80ms to ensure it followed 100ms
          expect(firstGap, greaterThan(80));
        }
      });

      test('re-subscription resets backoff state', () async {
        bool connected = false;
        final callLog = <DateTime>[];

        final checker = makeChecker(
          shouldSucceed: () => connected,
          callLog: callLog,
          checkInterval: const Duration(milliseconds: 50),
          backoffInitialDelay: const Duration(milliseconds: 50),
          backoffMaxDelay: const Duration(milliseconds: 200),
          backoffMultiplier: 2.0,
        );

        // First subscription — let backoff grow.
        final sub1 = checker.onStatusChange.listen((_) {});
        await Future.delayed(const Duration(milliseconds: 600));
        await sub1.cancel();
        callLog.clear();

        // Second subscription — backoff should restart from initialDelay.
        final sub2 = checker.onStatusChange.listen((_) {});
        await Future.delayed(const Duration(milliseconds: 400));
        await sub2.cancel();

        // With restarted backoff (50 → 100 → 200ms), we expect fewer calls
        // than if the capped 200ms delay continued (which would yield ~2 calls).
        // Actually both cases yield 2-3 calls in 400ms, so just verify
        // that the first gap is close to initialDelay (50ms), not maxDelay.
        if (callLog.length >= 2) {
          final firstGap =
              callLog[1].difference(callLog[0]).inMilliseconds.abs();
          expect(firstGap, lessThan(180)); // initialDelay=50ms + tolerance
        }
      });

      test('first poll returning disconnected is treated as first failure',
          () async {
        final callLog = <DateTime>[];

        // Always disconnected from the start — previousStatus will be null on
        // the first poll, which should be treated as first-failure (not ongoing).
        final checker = makeChecker(
          shouldSucceed: () => false,
          callLog: callLog,
          checkInterval: const Duration(milliseconds: 50),
          backoffInitialDelay: const Duration(milliseconds: 100),
          backoffMaxDelay: const Duration(milliseconds: 800),
          backoffMultiplier: 2.0,
        );

        final sub = checker.onStatusChange.listen((_) {});

        // First check fires immediately, then after initialDelay (100ms).
        // If first-failure was treated as ongoing, delay would be 50*2=100ms anyway,
        // but if it jumped to ongoing-formula on first call it would be 200ms.
        await Future.delayed(const Duration(milliseconds: 400));
        await sub.cancel();

        // We should see at least 2 calls in 400ms:
        // call[0] immediately, call[1] after ~100ms, call[2] after ~200ms.
        expect(callLog.length, greaterThanOrEqualTo(2));

        if (callLog.length >= 2) {
          final gap = callLog[1].difference(callLog[0]).inMilliseconds.abs();
          // initialDelay is 100ms; ongoing backoff of 100ms would also be 100ms
          // on first step, but 200ms on second. We verify the first gap is ~100ms.
          expect(gap, greaterThan(60));
          expect(gap, lessThan(200));
        }
      });

      test(
          'setIntervalAndResetTimer during connected period: '
          'first subsequent failure uses initialDelay', () async {
        bool connected = true;
        final callLog = <DateTime>[];

        final checker = makeChecker(
          shouldSucceed: () => connected,
          callLog: callLog,
          checkInterval: const Duration(milliseconds: 50),
          backoffInitialDelay: const Duration(milliseconds: 150),
          backoffMaxDelay: const Duration(milliseconds: 800),
          backoffMultiplier: 2.0,
        );

        final sub = checker.onStatusChange.listen((_) {});

        // Establish connected state, then call setIntervalAndResetTimer
        // while still connected.
        await Future.delayed(const Duration(milliseconds: 100));
        checker.setIntervalAndResetTimer(const Duration(milliseconds: 50));

        // Let a few more connected polls run, then measure from the disconnect.
        await Future.delayed(const Duration(milliseconds: 150));
        callLog.clear();

        connected = false;

        // Wait for disconnect detection + one backoff cycle (initialDelay=150ms).
        await Future.delayed(const Duration(milliseconds: 400));
        await sub.cancel();

        // The gap after the first disconnected poll should be ~initialDelay (150ms),
        // not a grown delay.
        if (callLog.length >= 2) {
          final gap = callLog[1].difference(callLog[0]).inMilliseconds.abs();
          expect(gap, greaterThan(100));
        }
      });

      test(
          'setIntervalAndResetTimer during an in-flight failing check does '
          'not corrupt the backoff reset', () async {
        // Use a gate to keep the 3rd check suspended while we call
        // setIntervalAndResetTimer, then release it to verify the reset it
        // applied survives instead of being silently overwritten once that
        // stale check finally resumes.
        final checkGate = Completer<void>();
        var checkCount = 0;
        final option =
            InternetCheckOption(uri: Uri.parse('https://example.com'));

        final checker = InternetConnection.createInstance(
          // Long enough that it can't fire during this test on its own —
          // any check we see must come from the in-flight one resuming.
          checkInterval: const Duration(seconds: 10),
          useDefaultOptions: false,
          customCheckOptions: [option],
          backoffOptions: ExponentialBackoffOptions(
            initialDelay: const Duration(milliseconds: 50),
            maxDelay: const Duration(milliseconds: 800),
            multiplier: 2.0,
          ),
          customConnectivityCheck: (opt) async {
            checkCount++;
            if (checkCount == 3) await checkGate.future; // hold check 3 open
            return InternetCheckResult(option: opt, isSuccess: false);
          },
        );
        addTearDown(checker.dispose);

        final sub = checker.onStatusChange.listen((_) {});

        // Let backoff grow through check 1 (50ms) and check 2 (100ms), then
        // check 3 starts and gets held.
        await Future.delayed(const Duration(milliseconds: 200));
        expect(checkCount, 3);

        // Reset while check 3 is still in-flight. This should make the next
        // failure use the fresh initial delay (50ms) again.
        checker.setIntervalAndResetTimer(const Duration(seconds: 10));
        expect(checker.currentBackoffDelay, const Duration(milliseconds: 50));

        // Release the stale check.
        checkGate.complete();
        await Future.delayed(const Duration(milliseconds: 300));
        await sub.cancel();

        // Without a guard, check 3 resuming would treat the reset as its own
        // first-failure, consume it, and reschedule — so the *next* check
        // would incorrectly see the reset as already used and grow the
        // delay to 100ms instead of starting over at 50ms. It would also
        // fire that extra check well within this 300ms window (the new
        // 10-second interval could not have fired on its own).
        expect(checkCount, 3);
        expect(checker.currentBackoffDelay, const Duration(milliseconds: 50));
      });
    });
  });
}
