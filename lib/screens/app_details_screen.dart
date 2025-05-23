import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../widgets/risk_indicator.dart';
import 'package:device_apps/device_apps.dart';

class AppDetailsScreen extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onUninstallSuccess;

  const AppDetailsScreen({
    super.key,
    required this.app,
    required this.onUninstallSuccess,
  });

  Future<void> _showUninstallDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uninstall App'),
          content: Text('Are you sure you want to uninstall ${app.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  final result = await DeviceApps.uninstallApp(app.packageName);
                  log("Result : $result");
                  Navigator.of(context).pop();


                  if (result) {
                    onUninstallSuccess(); // Call the callback
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to uninstall app'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop(); // Dismiss loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Uninstall'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final highRiskPerms =
        app.permissions.where((p) => p['risk'] == 'High').toList();
    final mediumRiskPerms =
        app.permissions.where((p) => p['risk'] == 'Medium').toList();
    final lowRiskPerms =
        app.permissions.where((p) => p['risk'] == 'Low').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              DeviceApps.openAppSettings(app.packageName);
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () => _showUninstallDialog(context),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (app.appIcon != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(app.appIcon!, width: 64, height: 64),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          app.packageName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPermissionSection(
                    context,
                    'High Risk Permissions',
                    highRiskPerms,
                    Colors.red.shade100,
                    Colors.red,
                  ),
                  _buildPermissionSection(
                    context,
                    'Medium Risk Permissions',
                    mediumRiskPerms,
                    Colors.orange.shade100,
                    Colors.orange,
                  ),
                  _buildPermissionSection(
                    context,
                    'Low Risk Permissions',
                    lowRiskPerms,
                    Colors.green.shade100,
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Risk Level',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RiskIndicator(riskLevel: app.riskLevel),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total Permissions: ${app.permissions.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection(
    BuildContext context,
    String title,
    List<Map<String, String>> permissions,
    Color backgroundColor,
    Color iconColor,
  ) {
    if (permissions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...permissions.map(
          (perm) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: backgroundColor,
            child: ListTile(
              leading: Icon(Icons.security, color: iconColor),
              title: Text(
                _formatPermissionName(perm['permission'] ?? ''),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPermissionName(String permission) {
    final parts = permission.split('.');
    final name = parts.last.replaceAll('_', ' ').toLowerCase();
    return name[0].toUpperCase() + name.substring(1);
  }
}
