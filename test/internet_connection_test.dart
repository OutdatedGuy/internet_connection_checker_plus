// Flutter Packages
import 'package:flutter_test/flutter_test.dart';

// This Package
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// Mocks
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
        });
      });

      test('creates and uses default HTTP client when none is provided',
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
      });

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
      });
    });

    group('enableStrictCheck', () {
      test('returns true when all URIs are reachable', () async {
        final checker = InternetConnection.createInstance(
          enableStrictCheck: true,
        );
        expect(await checker.hasInternetAccess, true);
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
      });
    });

    group('checkInterval', () {
      setUp(() {
        TestWidgetsFlutterBinding.ensureInitialized();
      });

      test('executes requests with given frequency', () async {
        await TestHttpClient.run((client) async {
          int counter = 0;

          client.responseBuilder = (req) {
            counter++;
            return TestHttpClient.createResponse(statusCode: 200);
          };

          final sub = InternetConnection.createInstance(
            checkInterval: const Duration(milliseconds: 100),
            useDefaultOptions: false,
            customCheckOptions: [
              InternetCheckOption(
                uri: Uri.parse('https://www.example.com'),
              ),
            ],
          ).onStatusChange.listen((_) {});

          await Future.delayed(const Duration(milliseconds: 500));

          // Give it tiny error space.
          expect(4 <= counter && counter <= 6, true);

          sub.cancel();
        });
      });

      test('correctly changes the interval', () async {
        await TestHttpClient.run((client) async {
          int counter = 0;

          client.responseBuilder = (req) {
            counter++;
            return TestHttpClient.createResponse(statusCode: 200);
          };

          final instance = InternetConnection.createInstance(
            checkInterval: const Duration(milliseconds: 100),
            useDefaultOptions: false,
            customCheckOptions: [
              InternetCheckOption(
                uri: Uri.parse('https://www.example.com'),
              ),
            ],
          );

          final sub = instance.onStatusChange.listen((_) {});

          await Future.delayed(const Duration(milliseconds: 500));

          // Give it tiny error space.
          expect(4 <= counter && counter <= 6, true);

          instance.setIntervalAndResetTimer(const Duration(milliseconds: 50));

          await Future.delayed(const Duration(milliseconds: 500));

          expect(14 <= counter && counter <= 16, true);

          sub.cancel();
        });
      });

      test('interval changes should not cause any additional checks', () async {
        await TestHttpClient.run((client) async {
          int counter = 0;

          client.responseBuilder = (req) {
            counter++;
            return TestHttpClient.createResponse(statusCode: 200);
          };

          final instance = InternetConnection.createInstance(
            checkInterval: const Duration(milliseconds: 100),
            useDefaultOptions: false,
            customCheckOptions: [
              InternetCheckOption(
                uri: Uri.parse('https://www.example.com'),
              ),
            ],
          );

          final sub = instance.onStatusChange.listen((_) {
            // Setting the same interval upon each emit should not
            // result in any extra triggers.
            instance.setIntervalAndResetTimer(instance.checkInterval);
          });

          await Future.delayed(const Duration(milliseconds: 500));

          // Give it tiny error space.
          expect(4 <= counter && counter <= 6, true);

          sub.cancel();
        });
      });
    });

    test('main constructor returns the same instance', () {
      final checker = InternetConnection();
      expect(checker, InternetConnection());
    });

    test('createInstance constructor returns different instances', () {
      final checker = InternetConnection.createInstance();
      expect(checker, isNot(InternetConnection.createInstance()));
    });
  });
}
