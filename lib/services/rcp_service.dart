import 'dart:ffi';
import 'dart:io' show Platform, Process, Directory;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import '../models/app_info.dart';
import '../utils/ffi_bridge.dart';
import '../utils/native_library.dart';

/// RCP service for interacting with the Rust FFI bridge
class RcpService {
  /// Singleton instance
  static final RcpService _instance = RcpService._internal();
  factory RcpService() => _instance;
  
  /// Dynamic library handle
  late DynamicLibrary _lib;
  
  /// Native function pointers
  late ConnectToServerDart _connectToServer;
  late AuthenticateUserDart _authenticateUser;
  late GetAvailableAppsDart _getAvailableApps;
  late LaunchAppDart _launchApp;
  
  /// Connection status
  bool _isInitialized = false;
  bool _isConnected = false;
  
  /// Get connection status
  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;

  /// Private constructor
  RcpService._internal();
  
  /// Initialize the FFI bridge
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // First, try to run the copy_macos_libs script to ensure libraries are in place
      try {
        if (await _ensureNativeLibraries()) {
          print('Native libraries successfully prepared');
        }
      } catch (e) {
        print('Warning: Failed to prepare native libraries: $e');
        // Continue with initialization anyway, as the libraries might still be accessible
      }
      
      // Now try loading the library
      _lib = await NativeLibrary.load();
      
      // Define native function mappings
      _connectToServer = _lib.lookupFunction<
        ConnectToServerNative,
        ConnectToServerDart
      >('connect_to_server');
      
      _authenticateUser = _lib.lookupFunction<
        AuthenticateUserNative,
        AuthenticateUserDart
      >('authenticate_user');
      
      _getAvailableApps = _lib.lookupFunction<
        GetAvailableAppsNative,
        GetAvailableAppsDart
      >('get_available_apps');
      
      _launchApp = _lib.lookupFunction<
        LaunchAppNative,
        LaunchAppDart
      >('launch_app');
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize RCP service: $e');
    }
  }
  
  /// Ensure native libraries are properly set up
  Future<bool> _ensureNativeLibraries() async {
    try {
      final result = await Process.run('./copy_macos_libs.sh', [], 
        workingDirectory: Directory.current.path);
      
      if (result.exitCode != 0) {
        print('Warning: Native library setup script exited with code ${result.exitCode}');
        print('stdout: ${result.stdout}');
        print('stderr: ${result.stderr}');
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error running native library setup: $e');
      return false;
    }
  }

  /// Connect to an RCP server
  Future<bool> connect(String host, int port) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final hostPointer = host.toNativeUtf8();
    
    try {
      final result = _connectToServer(hostPointer, port);
      
      if (result != FfiResultCodes.success) {
        throw Exception('Connection failed: ${FfiResultCodes.getMessage(result)}');
      }
      
      _isConnected = true;
      return true;
    } finally {
      calloc.free(hostPointer);
    }
  }

  /// Authenticate with the RCP server
  Future<bool> authenticate(String username, String password) async {
    if (!_isInitialized) {
      throw Exception('RCP service not initialized');
    }
    
    if (!_isConnected) {
      throw Exception('Not connected to RCP server');
    }
    
    final usernamePointer = username.toNativeUtf8();
    final passwordPointer = password.toNativeUtf8();
    
    try {
      final result = _authenticateUser(usernamePointer, passwordPointer);
      
      if (result != FfiResultCodes.success) {
        throw Exception('Authentication failed: ${FfiResultCodes.getMessage(result)}');
      }
      
      return true;
    } finally {
      calloc.free(usernamePointer);
      calloc.free(passwordPointer);
    }
  }

  /// Get available applications from the RCP server
  Future<List<AppInfo>> getAvailableApps() async {
    if (!_isInitialized) {
      throw Exception('RCP service not initialized');
    }
    
    if (!_isConnected) {
      throw Exception('Not connected to RCP server');
    }
    
    final countPtr = calloc<Int32>();
    
    try {
      // Call native function to get app list
      final appListPtr = _getAvailableApps(countPtr);
      final count = countPtr.value;
      
      // For now, return dummy data as the FFI implementation is incomplete
      return _getDummyAppList();
      
      /*
      // This will be implemented once the FFI function is complete
      final appList = <AppInfo>[];
      for (var i = 0; i < count; i++) {
        final appInfoJson = appListPtr.elementAt(i).value.toDartString();
        appList.add(AppInfo.fromJson(jsonDecode(appInfoJson)));
      }
      
      return appList;
      */
    } finally {
      calloc.free(countPtr);
    }
  }

  /// Launch an application by its ID
  Future<bool> launchApp(String appId) async {
    if (!_isInitialized) {
      throw Exception('RCP service not initialized');
    }
    
    if (!_isConnected) {
      throw Exception('Not connected to RCP server');
    }
    
    final appIdPointer = appId.toNativeUtf8();
    
    try {
      final result = _launchApp(appIdPointer);
      
      if (result != FfiResultCodes.success) {
        throw Exception('Failed to launch application: ${FfiResultCodes.getMessage(result)}');
      }
      
      return true;
    } finally {
      calloc.free(appIdPointer);
    }
  }
  
  /// Disconnect from the server
  void disconnect() {
    _isConnected = false;
    // We could add a proper FFI disconnect call here
  }
  
  /// Temporary function to get dummy app list for testing
  List<AppInfo> _getDummyAppList() {
    return [
      AppInfo(
        id: 'app1',
        name: 'Terminal',
        description: 'Command-line terminal',
        publisher: 'RCP System',
        version: '1.0.0',
        tags: ['utility', 'system'],
      ),
      AppInfo(
        id: 'app2',
        name: 'Text Editor',
        description: 'Simple text editor',
        publisher: 'RCP System',
        version: '1.2.0',
        tags: ['productivity', 'editor'],
      ),
      AppInfo(
        id: 'app3',
        name: 'File Browser',
        description: 'Browse and manage files',
        publisher: 'RCP System',
        version: '0.9.5',
        tags: ['utility', 'system'],
      ),
      AppInfo(
        id: 'app4',
        name: 'Web Browser',
        description: 'Browse the web',
        publisher: 'RCP Apps',
        version: '2.1.0',
        tags: ['internet', 'productivity'],
      ),
    ];
  }
}
