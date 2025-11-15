class UserDevice {
  final String id;              // uuid
  final String userId;          // uuid
  final String deviceId;        // texte (persistant)
  final String deviceName;      // ex: samsung SM-S918B, Windows PC
  final String deviceType;      // mobile | desktop | web
  final String platform;        // android | ios | windows | macos | linux | web
  final String? appVersion;
  final String? osVersion;
  final bool isAuthorized;      // TRUE si autorisé
  final bool isCurrentDevice;
  final DateTime? firstLoginAt;
  final DateTime? lastLoginAt;
  final String? ipAddress;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserDevice({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    this.appVersion,
    this.osVersion,
    required this.isAuthorized,
    required this.isCurrentDevice,
    this.firstLoginAt,
    this.lastLoginAt,
    this.ipAddress,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDevice.fromMap(Map<String, dynamic> m) => UserDevice(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        deviceId: m['device_id'] as String,
        deviceName: (m['device_name'] ?? '') as String,
        deviceType: (m['device_type'] ?? '') as String,
        platform: (m['platform'] ?? '') as String,
        appVersion: m['app_version'] as String?,
        osVersion: m['os_version'] as String?,
        isAuthorized: (m['is_authorized'] as bool?) ?? true,
        isCurrentDevice: (m['is_current_device'] as bool?) ?? false,
        firstLoginAt: m['first_login_at'] == null ? null : DateTime.parse(m['first_login_at']),
        lastLoginAt:  m['last_login_at']  == null ? null : DateTime.parse(m['last_login_at']),
        ipAddress: m['ip_address'] as String?,
        location:  m['location'] as String?,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at']),
        updatedAt: m['updated_at'] == null ? null : DateTime.parse(m['updated_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'device_id': deviceId,
        'device_name': deviceName,
        'device_type': deviceType,
        'platform': platform,
        'app_version': appVersion,
        'os_version': osVersion,
        'is_authorized': isAuthorized,
        'is_current_device': isCurrentDevice,
        'first_login_at': firstLoginAt?.toIso8601String(),
        'last_login_at':  lastLoginAt?.toIso8601String(),
        'ip_address': ipAddress,
        'location': location,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
