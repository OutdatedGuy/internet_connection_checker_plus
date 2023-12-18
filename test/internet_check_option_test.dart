import 'package:flutter_test/flutter_test.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

void main() {
  test(
    'InternetCheckOptions toString() should return correct string representation',
    () {
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
    },
  );
}
