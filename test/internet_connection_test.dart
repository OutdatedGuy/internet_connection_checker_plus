import 'package:flutter_test/flutter_test.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '__mocks__/test_http_client.dart';

void main() {
  group('InternetConnection', () {
    test('hasInternetAccess returns true for valid URIs', () async {
      final checker = InternetConnection();
      expect(await checker.hasInternetAccess, true);
    });

    test('hasInternetAccess returns false for invalid URIs', () async {
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

    test('hasInternetAccess invoke responseStatusFn to determine success',
        () async {
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

    test('hasInternetAccess send custom header on request', () async {
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
