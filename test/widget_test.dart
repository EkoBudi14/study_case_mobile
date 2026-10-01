// Unit tests for the RSSI helper logic (category, labels, distance).
// Pure Dart logic, so these run fast and without any plugins.

import 'package:flutter_test/flutter_test.dart';
import 'package:study_case_mobile_engineer/common/rssi_helper.dart';

void main() {
  group('RssiHelper.categoryOf', () {
    test('maps RSSI values to the categories from the spec table', () {
      expect(RssiHelper.categoryOf(-20), SignalCategory.veryStrong);
      expect(RssiHelper.categoryOf(-40), SignalCategory.strong);
      expect(RssiHelper.categoryOf(-60), SignalCategory.good);
      expect(RssiHelper.categoryOf(-75), SignalCategory.weak);
      expect(RssiHelper.categoryOf(-85), SignalCategory.veryWeak);
      expect(RssiHelper.categoryOf(-95), SignalCategory.lost);
    });

    test('handles the exact boundary values', () {
      expect(RssiHelper.categoryOf(-30), SignalCategory.veryStrong);
      expect(RssiHelper.categoryOf(-50), SignalCategory.strong);
      expect(RssiHelper.categoryOf(-70), SignalCategory.good);
      expect(RssiHelper.categoryOf(-80), SignalCategory.weak);
      expect(RssiHelper.categoryOf(-90), SignalCategory.veryWeak);
    });
  });

  group('RssiHelper.estimateMeters', () {
    test('a stronger signal is estimated closer than a weaker one', () {
      expect(
        RssiHelper.estimateMeters(-40) < RssiHelper.estimateMeters(-80),
        isTrue,
      );
    });

    test('roughly 1 meter at the reference TX power (-59 dBm)', () {
      final meters = RssiHelper.estimateMeters(-59);
      expect(meters, closeTo(1.0, 0.1));
    });
  });

  group('RssiHelper.proximity', () {
    test('returns a value between 0 and 1', () {
      expect(RssiHelper.proximity(-120), 0.0); // clamped
      expect(RssiHelper.proximity(-20), 1.0); // clamped
      final mid = RssiHelper.proximity(-70);
      expect(mid, greaterThan(0.0));
      expect(mid, lessThan(1.0));
    });
  });
}
