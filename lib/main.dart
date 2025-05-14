import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'screens/connection_screen.dart';
import 'utils/constants.dart';
import 'utils/native_library_manager.dart';
import 'utils/theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Prepare native libraries
  try {
    // Check if native libraries are available
    final librariesAvailable = await NativeLibraryManager.areLibrariesAvailable();
    
    if (!librariesAvailable) {
      print('Native libraries not found. Attempting to prepare them...');
      await NativeLibraryManager.prepareLibraries();
    }
  } catch (e) {
    print('Warning: Failed to prepare native libraries: $e');
    // Continue execution as the app may still work with network fallback
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
  
  @override
  void initState() {
    super.initState();
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  
  @override
  void dispose() {
    // Reset orientations
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appState,
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const ConnectionScreen(),
      ),
    );
  }
}
