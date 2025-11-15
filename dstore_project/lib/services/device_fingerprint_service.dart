
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceFingerprint {
  final String deviceId;
  final String deviceName;
  final String deviceType; // mobile | desktop | web
  final String platform;   // android | ios | windows | macos | linux | web
  final String? osVersion;
  final String? appVersion;

  DeviceFingerprint({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    this.osVersion,
    this.appVersion,
  });
}

class DeviceFingerprintService {
  DeviceFingerprintService._();
  static final DeviceFingerprintService instance = DeviceFingerprintService._();

  final _info = DeviceInfoPlugin();

  Future<String> _getOrCreate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(key);
    if (v != null && v.isNotEmpty) return v;
    final id = const Uuid().v4();
    await prefs.setString(key, id);
    return id;
  }

  Future<DeviceFingerprint> current() async {
    final pkg = await PackageInfo.fromPlatform().catchError((_) => null);
    final appVersion = pkg?.version;

    if (kIsWeb) {
      final web = await _info.webBrowserInfo;
      final id = await _getOrCreate('web_device_id');
      return DeviceFingerprint(
        deviceId: id,
        deviceName: web.browserName.name,
        deviceType: 'web',
        platform: 'web',
        osVersion: web.appVersion ?? '',
        appVersion: appVersion,
      );
    }

    if (Platform.isAndroid) {
      final a = await _info.androidInfo;
      final id = a.id ?? await _getOrCreate('android_fallback_id');
      return DeviceFingerprint(
        deviceId: id,
        deviceName: '${a.manufacturer} ${a.model}',
        deviceType: 'mobile',
        platform: 'android',
        osVersion: 'SDK ${a.version.sdkInt} (${a.version.release})',
        appVersion: appVersion,
      );
    }

    if (Platform.isIOS) {
      final i = await _info.iosInfo;
      final id = i.identifierForVendor ?? await _getOrCreate('ios_fallback_id');
      return DeviceFingerprint(
        deviceId: id,
        deviceName: i.utsname.machine ?? 'iPhone/iPad',
        deviceType: 'mobile',
        platform: 'ios',
        osVersion: i.systemVersion,
        appVersion: appVersion,
      );
    }

    if (Platform.isWindows) {
      final w = await _info.windowsInfo;
      final id = await _getOrCreate('windows_device_id');
      return DeviceFingerprint(
        deviceId: id,
        deviceName: w.computerName,
        deviceType: 'desktop',
        platform: 'windows',
        osVersion: 'Build ${w.buildNumber} ${w.productName}',
        appVersion: appVersion,
      );
    }

    if (Platform.isMacOS) {
      final m = await _info.macOsInfo;
      final id = await _getOrCreate('macos_device_id');
      return DeviceFingerprint(
        deviceId: id,
        deviceName: m.model,
        deviceType: 'desktop',
        platform: 'macos',
        osVersion: m.osRelease,
        appVersion: appVersion,
      );
    }

    if (Platform.isLinux) {
      final l = await _info.linuxInfo;
      final id = await _getOrCreate('linux_device_id');
      return DeviceFingerprint(
        deviceId: id,
        deviceName: l.prettyName ?? 'Linux',
        deviceType: 'desktop',
        platform: 'linux',
        osVersion: l.version ?? l.versionId ?? '',
        appVersion: appVersion,
      );
    }

    final id = await _getOrCreate('unknown_device_id');
    return DeviceFingerprint(
      deviceId: id,
      deviceName: 'Unknown',
      deviceType: 'desktop',
      platform: 'unknown',
      osVersion: null,
      appVersion: appVersion,
    );
  }
}
