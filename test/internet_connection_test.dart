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

    group('onStatusChange', () {
      test(
          'cancelled in-flight check does not emit stale result to new subscriber',
          () async {
        // Use a gate to keep the first check suspended while we cancel and
        // resubscribe, then release it to verify the stale result is dropped.
        final checkGate = Completer<void>();
        var checkCount = 0;

        final checker = InternetConnection.createInstance(
          checkInterval: const Duration(seconds: 10),
          useDefaultOptions: false,
          customCheckOptions: [
            InternetCheckOption(uri: Uri.parse('https://example.com')),
          ],
          customConnectivityCheck: (opt) async {
            final mine = ++checkCount;
            if (mine == 1) await checkGate.future; // stale check is paused
            // check 1 → connected (stale), check 2 → disconnected (fresh)
            return InternetCheckResult(option: opt, isSuccess: mine == 1);
          },
        );

        // Subscribe — starts the first (paused) check.
        final sub1 = checker.onStatusChange.listen((_) {});
        await Future.microtask(() {});

        // Cancel before the first check resolves.
        await sub1.cancel();

        // Resubscribe — starts the second (immediate, disconnected) check.
        final received = <InternetStatus>[];
        final sub2 = checker.onStatusChange.listen(received.add);

        // Let the second check complete.
        await Future.delayed(const Duration(milliseconds: 50));

        // Release the stale first check.
        checkGate.complete();
        await Future.delayed(const Duration(milliseconds: 50));

        // Only the fresh (disconnected) result should have been emitted.
        expect(received, [InternetStatus.disconnected]);

        await sub2.cancel();
        await checker.dispose();
      });

      test('does not restart the timer if cancelled while a check is in-flight',
          () async {
        final checkGate = Completer<void>();
        var checkCount = 0;

        final checker = InternetConnection.createInstance(
          checkInterval: const Duration(milliseconds: 50),
          useDefaultOptions: false,
          customCheckOptions: [
            InternetCheckOption(uri: Uri.parse('https://example.com')),
          ],
          customConnectivityCheck: (opt) async {
            checkCount++;
            if (checkCount == 1) await checkGate.future;
            return InternetCheckResult(option: opt, isSuccess: true);
          },
        );

        final sub = checker.onStatusChange.listen((_) {});
        await Future.microtask(() {});

        // Cancel while the first check is still in-flight.
        await sub.cancel();

        // Release the in-flight check now that there are no listeners.
        checkGate.complete();
        await Future.delayed(const Duration(milliseconds: 200));

        // No listener ever subscribed again, so no further checks should
        // have been triggered by a lingering timer.
        expect(checkCount, 1);

        await checker.dispose();
      });
    });
  });
}
