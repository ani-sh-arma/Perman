import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../widgets/risk_indicator.dart';

class AppDetailsScreen extends StatelessWidget {
  final AppInfo app;
  const AppDetailsScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    final highRiskPerms =
        app.permissions.where((p) => p['risk'] == 'High').toList();
    final mediumRiskPerms =
        app.permissions.where((p) => p['risk'] == 'Medium').toList();
    final lowRiskPerms =
        app.permissions.where((p) => p['risk'] == 'Low').toList();

    return Scaffold(
      appBar: AppBar(title: Text(app.name), elevation: 0),
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
