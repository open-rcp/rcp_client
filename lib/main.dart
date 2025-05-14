import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'screens/connection_screen.dart';
import 'utils/constants.dart';
import 'utils/library_utils.dart';
import 'utils/theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Prepare native libraries
  try {
    await LibraryUtils.prepareNativeLibraries();
  } catch (e) {
    print('Warning: Failed to prepare native libraries: $e');
  }
  
  runApp(const RcpClientApp());
}

/// RCP Client application root widget
class RcpClientApp extends StatefulWidget {
  const RcpClientApp({super.key});

  @override
  State<RcpClientApp> createState() => _RcpClientAppState();
}

class _RcpClientAppState extends State<RcpClientApp> {
  final AppState _appState = AppState();
  ThemeMode _themeMode = ThemeMode.system;
  
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }
  
  /// Load theme mode preference from settings
  Future<void> _loadThemeMode() async {
    // We would load the theme mode from the SettingsService
    // For now, just use the default system theme
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _appState,
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: _themeMode,
        debugShowCheckedModeBanner: false,
        home: const ConnectionScreen(),
      ),
    );
  }
}
