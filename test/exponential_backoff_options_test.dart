import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:test/test.dart';

void main() {
  group('ExponentialBackoffOptions', () {
    test('toString() returns correct string representation', () {
      final options = ExponentialBackoffOptions(
        initialDelay: const Duration(milliseconds: 500),
        maxDelay: const Duration(seconds: 30),
        multiplier: 3.0,
      );

      const expectedString = 'ExponentialBackoffOptions(\n'
          '  initialDelay: 0:00:00.500000,\n'
          '  maxDelay: 0:00:30.000000,\n'
          '  multiplier: 3.0\n'
          ')';

      expect(options.toString(), expectedString);
    });

    test('two instances with the same values are equal', () {
      final a = ExponentialBackoffOptions(
        initialDelay: const Duration(milliseconds: 500),
        maxDelay: const Duration(seconds: 30),
        multiplier: 3.0,
      );
      final b = ExponentialBackoffOptions(
        initialDelay: const Duration(milliseconds: 500),
        maxDelay: const Duration(seconds: 30),
        multiplier: 3.0,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    group('constructor validation', () {
      // multiplier < 1.0 would cause the delay to shrink on each failure,
      // eventually collapsing to 0 and creating a busy-poll loop.
      test('throws when multiplier is less than 1.0', () {
        expect(
          () => ExponentialBackoffOptions(multiplier: 0.5),
          throwsA(isA<AssertionError>()),
        );
      });

      // 1.0 is the boundary: flat-rate backoff (delay never grows) is valid,
      // since the interval still resets on reconnect as documented.
      test('allows multiplier equal to 1.0', () {
        expect(
          () => ExponentialBackoffOptions(multiplier: 1.0),
          returnsNormally,
        );
      });

      // Duration.zero initial delay fires the next timer immediately on the
      // first failure, indistinguishable from having no backoff at all.
      test('throws when initialDelay is zero', () {
        expect(
          () => ExponentialBackoffOptions(initialDelay: Duration.zero),
          throwsA(isA<AssertionError>()),
        );
      });

      // initialDelay > maxDelay means the very first backed-off poll already
      // exceeds the configured ceiling — the ceiling becomes meaningless.
      test('throws when initialDelay exceeds maxDelay', () {
        expect(
          () => ExponentialBackoffOptions(
            initialDelay: const Duration(seconds: 10),
            maxDelay: const Duration(seconds: 5),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when maxDelay is zero', () {
        expect(
          () => ExponentialBackoffOptions(maxDelay: Duration.zero),
          throwsA(isA<AssertionError>()),
        );
      });

      // NaN and Infinity both fail `< 1.0` (IEEE-754 comparisons involving
      // NaN are always false), so a naive lower-bound check alone would let
      // them through only to crash later when `.round()` is called on the
      // grown delay during an ongoing failure.
      test('throws when multiplier is NaN', () {
        expect(
          () => ExponentialBackoffOptions(multiplier: double.nan),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when multiplier is Infinity', () {
        expect(
          () => ExponentialBackoffOptions(multiplier: double.infinity),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('resolveInitialDelay', () {
      test('falls back to checkInterval when initialDelay is omitted', () {
        final options = ExponentialBackoffOptions();

        expect(
          options.resolveInitialDelay(const Duration(seconds: 10)),
          const Duration(seconds: 10),
        );
      });

      test('uses the explicit initialDelay when provided', () {
        final options = ExponentialBackoffOptions(
          initialDelay: const Duration(milliseconds: 200),
        );

        expect(
          options.resolveInitialDelay(const Duration(seconds: 10)),
          const Duration(milliseconds: 200),
        );
      });

      test('caps the resolved delay at maxDelay', () {
        final options = ExponentialBackoffOptions(
          maxDelay: const Duration(milliseconds: 100),
        );

        expect(
          options.resolveInitialDelay(const Duration(seconds: 10)),
          const Duration(milliseconds: 100),
        );
      });
    });

    group('nextDelay', () {
      test('returns the resolved initial delay on first failure', () {
        final options = ExponentialBackoffOptions(
          initialDelay: const Duration(milliseconds: 100),
        );

        expect(
          options.nextDelay(
            current: const Duration(milliseconds: 400),
            isFirstFailure: true,
            checkInterval: const Duration(seconds: 10),
          ),
          const Duration(milliseconds: 100),
        );
      });

      test('grows the current delay by multiplier on an ongoing failure', () {
        final options = ExponentialBackoffOptions(multiplier: 2.0);

        expect(
          options.nextDelay(
            current: const Duration(milliseconds: 100),
            isFirstFailure: false,
            checkInterval: const Duration(seconds: 10),
          ),
          const Duration(milliseconds: 200),
        );
      });

      test('caps the grown delay at maxDelay', () {
        final options = ExponentialBackoffOptions(
          maxDelay: const Duration(milliseconds: 150),
          multiplier: 2.0,
        );

        expect(
          options.nextDelay(
            current: const Duration(milliseconds: 100),
            isFirstFailure: false,
            checkInterval: const Duration(seconds: 10),
          ),
          const Duration(milliseconds: 150),
        );
      });
    });
  });
}
