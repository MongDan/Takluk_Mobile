import 'package:flutter/foundation.dart';
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
    final cached = await _storage.read(key: 'device_id');
    if (cached != null && cached.isNotEmpty) return cached;

    // Generate from platform (tanpa dart:io agar tetap aman di web/desktop)
    String deviceId;
    if (kIsWeb) {
      deviceId = 'web-device-${DateTime.now().millisecondsSinceEpoch}';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final android = await _deviceInfo.androidInfo;
      deviceId = android.id;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = await _deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor ?? 'ios-unknown';
    } else {
      deviceId = 'desktop-device-${DateTime.now().millisecondsSinceEpoch}';
    }

    await _storage.write(key: 'device_id', value: deviceId);
    return deviceId;
  }

  Future<String> getDeviceModel() async {
    if (kIsWeb) {
      final web = await _deviceInfo.webBrowserInfo;
      return '${web.browserName.name} • ${web.platform ?? 'Web'}';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = await _deviceInfo.androidInfo;
      return '${android.brand} ${android.model}';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = await _deviceInfo.iosInfo;
      return ios.utsname.machine;
    }
    return 'Desktop Device';
  }
}

