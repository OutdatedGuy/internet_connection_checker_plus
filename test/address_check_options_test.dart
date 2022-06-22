import 'dart:io';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'should verify toString() method',
    () {
      // Setup - Arrange
      final InternetAddress tInternetAddress = InternetAddress('1.1.1.1');
      const int defaultPort = 43;
      const Duration defaultTimeout = Duration(seconds: 10);
      final AddressCheckOptions tOptions = AddressCheckOptions(
        tInternetAddress,
        port: defaultPort,
      );
      // Action - Act

      // Result - Assert
      expect(
        tOptions.toString(),
        'AddressCheckOptions($tInternetAddress, $defaultPort, $defaultTimeout)',
      );
    },
  );
}
