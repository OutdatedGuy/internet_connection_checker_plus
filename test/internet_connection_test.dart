import 'package:flutter_test/flutter_test.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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
