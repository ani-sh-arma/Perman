import 'package:flutter/material.dart';
import 'package:perman/screens/app_details_screen.dart';
import 'package:perman/utils/debouncer.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer();
  bool _showSystemApps = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    await _appService.fetchInstalledApps(includeSystemApps: _showSystemApps);
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
      appBar: AppBar(
        title: const Text('PerMan'),
        actions: [
          IconButton(
            icon: Icon(
              _showSystemApps ? Icons.android : Icons.android_outlined,
              color: _showSystemApps ? Theme.of(context).primaryColor : null,
            ),
            onPressed: () {
              setState(() {
                _showSystemApps = !_showSystemApps;
                _appService.fetchInstalledApps(
                  includeSystemApps: _showSystemApps,
                );
              });
            },
            tooltip: 'Toggle System Apps',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                _debouncer(() {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _appService.fetchInstalledApps(
                includeSystemApps: _showSystemApps,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredApps =
                    _appService.installedApps
                        .where(
                          (app) =>
                              app.name.toLowerCase().contains(_searchQuery) ||
                              app.packageName.toLowerCase().contains(
                                _searchQuery,
                              ),
                        )
                        .toList();

                return ListView.builder(
                  itemCount: filteredApps.length,
                  itemBuilder: (context, index) {
                    final app = filteredApps[index];
                    return AppTile(
                      app: app,
                      onUninstallSuccess: () {
                        setState(() {
                          _appService.fetchInstalledApps(
                            includeSystemApps: _showSystemApps,
                          );
                        });
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AppDetailsScreen(
                                  app: app,
                                  onUninstallSuccess: () {
                                    setState(() {
                                      _appService.fetchInstalledApps(
                                        includeSystemApps: _showSystemApps,
                                      );
                                    });
                                  },
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
