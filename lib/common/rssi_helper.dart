import 'dart:math';
import 'package:flutter/material.dart';

enum SignalCategory { veryStrong, strong, good, weak, veryWeak, lost }

class RssiHelper {
  // Reference RSSI measured at 1 meter from a typical BLE device.
  static const int _txPowerAt1m = -59;
  // Environmental factor (2.0 = free space, higher = more obstacles).
  static const double _pathLossExponent = 2.0;

  /// Pick the category for a given RSSI using the thresholds from the spec.
  static SignalCategory categoryOf(int rssi) {
    if (rssi >= -30) return SignalCategory.veryStrong;
    if (rssi >= -50) return SignalCategory.strong;
    if (rssi >= -70) return SignalCategory.good;
    if (rssi >= -80) return SignalCategory.weak;
    if (rssi >= -90) return SignalCategory.veryWeak;
    return SignalCategory.lost;
  }

  static String label(int rssi) {
    switch (categoryOf(rssi)) {
      case SignalCategory.veryStrong:
        return 'Sangat Kuat';
      case SignalCategory.strong:
        return 'Kuat';
      case SignalCategory.good:
        return 'Cukup / Baik';
      case SignalCategory.weak:
        return 'Lemah';
      case SignalCategory.veryWeak:
        return 'Sangat Lemah';
      case SignalCategory.lost:
        return 'Sinyal Hilang';
    }
  }

  /// The approximate distance range text from the spec's table.
  static String rangeText(int rssi) {
    switch (categoryOf(rssi)) {
      case SignalCategory.veryStrong:
        return '< 1 meter';
      case SignalCategory.strong:
        return '1 - 3 meter';
      case SignalCategory.good:
        return '3 - 10 meter';
      case SignalCategory.weak:
        return '10 - 20 meter';
      case SignalCategory.veryWeak:
        return '> 20 meter';
      case SignalCategory.lost:
        return 'Di luar jangkauan';
    }
  }

  static Color color(int rssi) {
    switch (categoryOf(rssi)) {
      case SignalCategory.veryStrong:
        return const Color(0xFF2E7D32);
      case SignalCategory.strong:
        return const Color(0xFF66BB6A);
      case SignalCategory.good:
        return const Color(0xFFF9A825);
      case SignalCategory.weak:
        return const Color(0xFFEF6C00);
      case SignalCategory.veryWeak:
        return const Color(0xFFD84315);
      case SignalCategory.lost:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Estimate distance in meters from RSSI using the log-distance path-loss
  /// formula:  distance = 10 ^ ((txPower - rssi) / (10 * n))
  static double estimateMeters(int rssi) {
    if (rssi == 0) return -1; // unknown
    final ratio = (_txPowerAt1m - rssi) / (10 * _pathLossExponent);
    return pow(10, ratio).toDouble();
  }

  /// Nicely formatted distance string, e.g. "2.3 m".
  static String metersText(int rssi) {
    final meters = estimateMeters(rssi);
    if (meters < 0) return '—';
    if (meters < 1) return '< 1 m';
    if (meters < 10) return '${meters.toStringAsFixed(1)} m';
    return '${meters.toStringAsFixed(0)} m';
  }

  /// Normalized closeness between 0.0 (far / lost) and 1.0 (very close).
  /// Used to size the dot on the radar view. We map RSSI from -100..-40.
  static double proximity(int rssi) {
    const minRssi = -100.0;
    const maxRssi = -40.0;
    final clamped = rssi.toDouble().clamp(minRssi, maxRssi);
    return (clamped - minRssi) / (maxRssi - minRssi);
  }
}
