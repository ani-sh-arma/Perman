import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../screens/app_details_screen.dart';

class AppTile extends StatelessWidget {
  final AppInfo app;
  const AppTile({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          app.appIcon != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(app.appIcon!, width: 64, height: 64),
              )
              : Icon(Icons.apps),
      title: Text(app.name),
      subtitle: Text("Risk Level: ${app.riskLevel}"),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppDetailsScreen(app: app)),
          ),
    );
  }
}
