import 'package:flutter_test/flutter_test.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

void main() {
  group('InternetCheckOption', () {
    test('toString() returns correct string representation', () {
      final options = InternetCheckOption(
        uri: Uri.parse('https://example.com'),
        timeout: const Duration(seconds: 5),
      );

      const expectedString = 'InternetCheckOption(\n'
          '  uri: https://example.com,\n'
          '  timeout: 0:00:05.000000,\n'
          '  headers: {}\n'
          ')';

      expect(options.toString(), expectedString);
    });

    group('headers', () {
      test('are empty if not set', () {
        final options = InternetCheckOption(
          uri: Uri.parse('https://example.com'),
        );

        expect(options.headers, {});
      });

      test('are set correctly', () {
        const headers = {'key': 'value'};

        final options = InternetCheckOption(
          uri: Uri.parse('https://example.com'),
          headers: headers,
        );

        expect(options.headers, headers);
      });
    });

    group('responseStatusFn', () {
      test('is equal to defaultResponseStatusFn if not set', () {
        final options1 = InternetCheckOption(
          uri: Uri.parse('https://example.com'),
        );

        expect(
          options1.responseStatusFn,
          equals(InternetCheckOption.defaultResponseStatusFn),
        );
      });

      test('is set correctly', () {
        customResponseStatusFn(response) => true;

        final options1 = InternetCheckOption(
          uri: Uri.parse('https://example.com'),
          responseStatusFn: customResponseStatusFn,
        );

        expect(options1.responseStatusFn, equals(customResponseStatusFn));
        expect(
          options1.responseStatusFn,
          isNot(equals(InternetCheckOption.defaultResponseStatusFn)),
        );
      });
    });

    group('defaultResponseStatusFn', () {
      test('can be overriden', () {
        final options = InternetCheckOption(
          uri: Uri.parse('https://example.com'),
        );

        InternetCheckOption.defaultResponseStatusFn = (response) => true;

        expect(
          options.responseStatusFn,
          isNot(equals(InternetCheckOption.defaultResponseStatusFn)),
        );
      });

      test('override is used', () {
        customResponseStatusFn(response) => true;

        InternetCheckOption.defaultResponseStatusFn = customResponseStatusFn;

        final options = InternetCheckOption(
          uri: Uri.parse('https://example.com'),
        );

        expect(options.responseStatusFn, equals(customResponseStatusFn));
      });
    });
  });
}
