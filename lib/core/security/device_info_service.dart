import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService(ref.read(secureStorageProvider));
});

class DeviceInfoService {
  final FlutterSecureStorage _storage;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  DeviceInfoService(this._storage);

  Future<String> getDeviceId() async {
    // Check cached device ID first
    String? cached = await _storage.read(key: 'device_id');
    if (cached != null) return cached;

    // Generate from platform
    String deviceId;
    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      deviceId = android.id;
    } else if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor ?? 'ios-unknown';
    } else {
      deviceId = 'demo-device-${DateTime.now().millisecondsSinceEpoch}';
    }

    await _storage.write(key: 'device_id', value: deviceId);
    return deviceId;
  }

  Future<String> getDeviceModel() async {
    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      return '${android.brand} ${android.model}';
    } else if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      return ios.utsname.machine;
    }
    return 'Unknown Device';
  }
}
