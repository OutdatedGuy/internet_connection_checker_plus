import 'package:flutter_test/flutter_test.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

void main() {
  group('InternetCheckResult', () {
    test('toString() returns correct string representation', () {
      InternetCheckOption option = InternetCheckOption(
        uri: Uri.parse('https://example.com'),
        timeout: const Duration(seconds: 3),
      );
      InternetCheckResult result = InternetCheckResult(
        option: option,
        isSuccess: true,
      );

      String expectedString = 'InternetCheckResult(\n'
          '  option: InternetCheckOption(\n'
          '    uri: https://example.com,\n'
          '    timeout: 0:00:03.000000,\n'
          '    headers: {}\n'
          '  ),\n'
          '  isSuccess: true\n'
          ')';

      expect(result.toString(), expectedString);
    });

    test('with different options are not equal', () {
      InternetCheckOption option1 = InternetCheckOption(
        uri: Uri.parse('https://example.com'),
        timeout: const Duration(seconds: 3),
      );
      InternetCheckOption option2 = InternetCheckOption(
        uri: Uri.parse('https://example.org'),
        timeout: const Duration(seconds: 5),
      );
      InternetCheckResult result1 = InternetCheckResult(
        option: option1,
        isSuccess: true,
      );
      InternetCheckResult result2 = InternetCheckResult(
        option: option2,
        isSuccess: true,
      );

      expect(result1, isNot(equals(result2)));
    });
  });
}
