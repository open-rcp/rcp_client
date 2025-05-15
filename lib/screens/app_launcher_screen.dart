import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_info.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';
import '../services/rcp_service.dart';
import '../utils/constants.dart';
import '../widgets/app_card.dart';
import '../widgets/copyable_error_message.dart';
import 'connection_screen.dart';
import 'streaming_screen.dart';

/// Screen for displaying and launching available applications
class AppLauncherScreen extends StatefulWidget {
  const AppLauncherScreen({super.key});

  @override
  State<AppLauncherScreen> createState() => _AppLauncherScreenState();
}

class _AppLauncherScreenState extends State<AppLauncherScreen> {
  final _rcpService = RcpService();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAvailableApps();
  }

  /// Fetch available applications from the server
  Future<void> _fetchAvailableApps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apps = await _rcpService.getAvailableApps();

      if (!mounted) return;

      // Update app state with available apps
      final appState = context.read<AppState>();
      appState.setApps(apps);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch applications: $e';
        _isLoading = false;
      });
    }
  }

  /// Launch an application by ID
  Future<void> _launchApp(AppInfo app) async {
    setState(() => _isLoading = true);

    try {
      final success = await _rcpService.launchApp(app.id);

      if (success) {
        if (!mounted) return;

        // Update app state with active app
        final appState = context.read<AppState>();
        appState.setActiveApp(app.id);

        // Navigate to streaming screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StreamingScreen(appInfo: app),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to launch application: ${app.name}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Application launch error: $e';
        _isLoading = false;
      });
    }
  }

  /// Logout the current user
  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    // Reset app state
    final appState = context.read<AppState>();
    appState.logout();

    // Navigate back to connection screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ConnectionScreen()),
    );
  }

  /// Refresh the list of available applications
  Future<void> _refreshApps() async {
    await _fetchAvailableApps();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final apps = appState.apps;
    final user = appState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        automaticallyImplyLeading: false,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshApps,
            tooltip: 'Refresh Applications',
          ),
          // User menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              child: Text(
                user.displayName?.substring(0, 1).toUpperCase() ??
                    user.username.substring(0, 1).toUpperCase(),
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      user.displayName ?? user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          _isLoading && apps.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _buildAppGrid(apps),
    );
  }

  Widget _buildAppGrid(List<AppInfo> apps) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.app_shortcut, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No applications available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CopyableErrorMessage(
                  message: _errorMessage!,
                  title: 'Application Error',
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _refreshApps,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshApps,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate how many cards can fit in a row based on screen width
            final cardWidth = AppConstants.appCardWidth;
            final crossAxisCount =
                (constraints.maxWidth / (cardWidth + 16)).floor();

            return GridView.count(
              crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
              childAspectRatio:
                  AppConstants.appCardWidth / AppConstants.appCardHeight,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children:
                  apps
                      .map(
                        (app) =>
                            AppCard(app: app, onTap: () => _launchApp(app)),
                      )
                      .toList(),
            );
          },
        ),
      ),
    );
  }
}
