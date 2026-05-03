import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wms_app/services/device_identity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceIdentityService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('gera e mantem o mesmo device_id local', () async {
      final service = DeviceIdentityService.instance;

      final first = await service.getOrCreateDeviceId();
      final second = await service.getOrCreateDeviceId();

      expect(first, isNotEmpty);
      expect(second, first);
      expect(
        first,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('reaproveita identificador legado do apontamento de paletes',
        () async {
      const legacyDeviceId = 'APP-legacy-device-id';
      SharedPreferences.setMockInitialValues({
        'stretch_device_id': legacyDeviceId,
      });

      final service = DeviceIdentityService.instance;
      final migrated = await service.getOrCreateDeviceId();
      final prefs = await SharedPreferences.getInstance();

      expect(migrated, legacyDeviceId);
      expect(
        prefs.getString(DeviceIdentityService.deviceIdKey),
        legacyDeviceId,
      );
    });
  });
}
