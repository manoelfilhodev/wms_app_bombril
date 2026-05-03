import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentityService {
  DeviceIdentityService._();

  static final DeviceIdentityService instance = DeviceIdentityService._();

  static const String deviceIdKey = 'systex_wms_device_id';
  static const String _legacyStretchDeviceIdKey = 'stretch_device_id';

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(deviceIdKey)?.trim();
    if (current != null && current.isNotEmpty) return current;

    final legacy = prefs.getString(_legacyStretchDeviceIdKey)?.trim();
    if (legacy != null && legacy.isNotEmpty) {
      await prefs.setString(deviceIdKey, legacy);
      return legacy;
    }

    final generated = _generateUuidV4();
    await prefs.setString(deviceIdKey, generated);
    return generated;
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
