import 'dart:developer';

/// Holds FCM data from a terminated-state launch. Captured in [initilization]
/// before [runApp], then consumed after the navigator exists.
class FcmPendingNavigation {
  static Map<String, dynamic>? _terminatedLaunchData;

  static void bufferTerminatedLaunchData(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    _terminatedLaunchData = Map<String, dynamic>.from(data);
    log('FcmPendingNavigation: buffered terminated launch data keys=${data.keys.toList()}');
  }

  /// Returns and clears buffered data (single consumer).
  static Map<String, dynamic>? takeTerminatedLaunchData() {
    final d = _terminatedLaunchData;
    _terminatedLaunchData = null;
    return d;
  }

  static bool get hasPending => _terminatedLaunchData != null;
}
