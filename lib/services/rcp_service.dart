import 'dart:convert';
import 'dart:io' show Platform;
import '../models/app_info.dart';
import '../utils/native_library_manager.dart';
import 'rcp_bridge.dart';

/// Service for interacting with RCP server via the Rust FFI bridge
class RcpService {
  final RcpBridge _bridge = RcpBridge();
  bool _isConnected = false;
  bool _isInitialized = false;
  
  /// Get connection status
  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  
  /// Initialize the RCP client
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check if native libraries are available
      final librariesAvailable = await NativeLibraryManager.areLibrariesAvailable();
      
      if (!librariesAvailable) {
        print('Native libraries not found. Attempting to prepare them...');
        await NativeLibraryManager.prepareLibraries();
      }
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing RCP service: $e');
      rethrow;
    }
  }
  
  /// Connect to RCP server
  Future<bool> connect(String host, int port) async {
    try {
      final result = await _bridge.initConnection(host, port);
      _isConnected = result['success'] as bool;
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }
  
  /// Authenticate a user
  Future<Map<String, dynamic>> authenticate(String username, String password) async {
    final result = await _bridge.authenticate(username, password);
    
    if (result['success'] as bool) {
      final userData = jsonDecode(result['data'] as String);
      return userData;
    } else {
      throw Exception(result['error'] ?? 'Authentication failed');
    }
  }
  
  /// Get available applications
  Future<List<AppInfo>> getAvailableApps() async {
    final result = await _bridge.getAvailableApps();
    
    if (result['success'] as bool) {
      final List<dynamic> appsData = jsonDecode(result['data'] as String);
      return appsData.map((appData) => AppInfo.fromJson(appData)).toList();
    } else {
      throw Exception(result['error'] ?? 'Failed to fetch available apps');
    }
  }
  
  /// Launch an application
  Future<bool> launchApp(String appId) async {
    final result = await _bridge.launchApp(appId);
    return result['success'] as bool;
  }
  
  /// Logout the current user
  Future<bool> logout() async {
    final result = await _bridge.logout();
    return result['success'] as bool;
  }
}
