class DeviceModel {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceType; // 'mobile', 'tablet', 'desktop'
  final String platform; // 'android', 'ios', 'windows', 'web'
  final String appVersion;
  final String osVersion;
  final bool isAuthorized;
  final bool isCurrentDevice;
  final DateTime firstLoginAt;
  final DateTime lastLoginAt;
  final String? ipAddress;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    required this.appVersion,
    required this.osVersion,
    required this.isAuthorized,
    required this.isCurrentDevice,
    required this.firstLoginAt,
    required this.lastLoginAt,
    this.ipAddress,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      deviceType: json['device_type'] as String,
      platform: json['platform'] as String,
      appVersion: json['app_version'] as String,
      osVersion: json['os_version'] as String,
      isAuthorized: json['is_authorized'] as bool? ?? false,
      isCurrentDevice: json['is_current_device'] as bool? ?? false,
      firstLoginAt: DateTime.parse(json['first_login_at'] as String),
      lastLoginAt: DateTime.parse(json['last_login_at'] as String),
      ipAddress: json['ip_address'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'first_login_at': firstLoginAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'ip_address': ipAddress,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeviceModel copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? platform,
    String? appVersion,
    String? osVersion,
    bool? isAuthorized,
    bool? isCurrentDevice,
    DateTime? firstLoginAt,
    DateTime? lastLoginAt,
    String? ipAddress,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      osVersion: osVersion ?? this.osVersion,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
      firstLoginAt: firstLoginAt ?? this.firstLoginAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get deviceDisplayName {
    return '$deviceName ($platform)';
  }

  String get statusText {
    if (isCurrentDevice) return 'Appareil actuel';
    if (isAuthorized) return 'Autorisé';
    return 'En attente d\'autorisation';
  }

  String get lastLoginText {
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${lastLoginAt.day}/${lastLoginAt.month}/${lastLoginAt.year}';
    }
  }

  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'android':
        return '🤖';
      case 'ios':
        return '📱';
      case 'windows':
        return '💻';
      case 'macos':
        return '🖥️';
      case 'web':
        return '🌐';
      default:
        return '📱';
    }
  }

  String get deviceTypeIcon {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
        return '📱';
      case 'tablet':
        return '📱';
      case 'desktop':
        return '💻';
      case 'web':
        return '🌐';
      default:
        return '📱';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeviceModel(id: $id, deviceName: $deviceName, platform: $platform, isAuthorized: $isAuthorized)';
  }
}
