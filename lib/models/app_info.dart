import 'dart:typed_data';

class AppInfo {
  final String name;
  final List<Map<String, String>> permissions;
  final String riskLevel;
  final String packageName;
  final Uint8List? appIcon;

  AppInfo({
    required this.name,
    required this.permissions,
    required this.riskLevel,
    required this.packageName,
    this.appIcon,
  });
}
