import 'package:device_apps/device_apps.dart';
import '../models/app_info.dart';
import 'package:flutter/services.dart';

class AppService {
  List<AppInfo> installedApps = [];

  Future<void> fetchInstalledApps({bool includeSystemApps = false}) async {
    try {
      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeSystemApps: includeSystemApps,
        onlyAppsWithLaunchIntent: true,
        includeAppIcons: true,
      );
      // apps =
      //     apps.where((app) {
      //       final package = app.packageName.toLowerCase();
      //       return !package.startsWith('com.android.') &&
      //           !package.startsWith('android');
      //     }).toList();

      print('Number of apps fetched by DeviceApps: ${apps.length}');

      installedApps = await Future.wait(
        apps.map((app) async {
          final androidApp = app as ApplicationWithIcon;
          final permissions = await _getAppPermissions(androidApp.packageName);
          final riskLevel = _calculateOverallRisk(permissions);

          print(
            'Processing app: ${app.appName}, Package: ${app.packageName}',
          ); // Debug log

          return AppInfo(
            packageName: app.packageName,
            appIcon: app.icon,
            name: app.appName,
            permissions:
                permissions
                    .map(
                      (p) => {
                        'permission': p,
                        'risk': _getPermissionRiskLevel(p),
                      },
                    )
                    .toList(),
            riskLevel: riskLevel,
          );
        }),
      );

      print(
        'Number of AppInfo objects created: ${installedApps.length}',
      ); // Debug log
    } catch (e) {
      print('Error fetching installed apps: $e');
      // Handle the error appropriately
    }
  }

  static const platform = MethodChannel('com.example.perman/permissions');

  Future<List<String>> _getAppPermissions(String packageName) async {
    try {
      final List<dynamic> permissions = await platform.invokeMethod(
        'getPermissions',
        packageName,
      );
      print('Permissions for $packageName: $permissions'); // Debug log
      return permissions.cast<String>();
    } catch (e) {
      print('Error getting permissions for $packageName: $e');
      return [];
    }
  }

  Map<String, String> get permissionRiskDatabase => {
    'android.permission.CAMERA': 'High',
    'android.permission.RECORD_AUDIO': 'High',
    'android.permission.ACCESS_FINE_LOCATION': 'High',
    'android.permission.READ_CONTACTS': 'High',
    'android.permission.READ_SMS': 'High',
    'android.permission.SEND_SMS': 'High',
    'android.permission.READ_CALL_LOG': 'High',
    'android.permission.READ_EXTERNAL_STORAGE': 'Medium',
    'android.permission.WRITE_EXTERNAL_STORAGE': 'Medium',
    'android.permission.ACCESS_COARSE_LOCATION': 'Medium',
    'android.permission.READ_CALENDAR': 'Medium',
    'android.permission.ACCESS_NETWORK_STATE': 'Low',
    'android.permission.INTERNET': 'Low',
    'android.permission.VIBRATE': 'Low',
    'android.permission.BLUETOOTH': 'Low',
  };

  String _getPermissionRiskLevel(String permission) {
    return permissionRiskDatabase[permission] ?? 'Low';
  }

  String _calculateOverallRisk(List<String> permissions) {
    int highRiskCount = 0;
    int mediumRiskCount = 0;

    for (var permission in permissions) {
      String risk = _getPermissionRiskLevel(permission);
      if (risk == 'High') highRiskCount++;
      if (risk == 'Medium') mediumRiskCount++;
    }

    if (highRiskCount > 0) return 'High';
    if (mediumRiskCount > 0) return 'Medium';
    return 'Low';
  }
}
