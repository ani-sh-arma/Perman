import 'package:flutter/material.dart';
import '../services/app_service.dart';
import '../widgets/app_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppService _appService = AppService();

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    await _appService.fetchInstalledApps();
    setState(() {});

    for (final app in _appService.installedApps) {
      print(
        "app.name: ${app.name} | app.riskLevel: ${app.riskLevel} | app.permissions: ${app.permissions}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perman')),
      body: ListView.builder(
        itemCount: _appService.installedApps.length,
        itemBuilder: (context, index) {
          final app = _appService.installedApps[index];
          return AppTile(app: app);
        },
      ),
    );
  }
}
