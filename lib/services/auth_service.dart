import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'rcp_service.dart';

/// Authentication service for user login and credential management
class AuthService {
  /// Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  /// Current user instance
  User _currentUser = User.guest();
  User get currentUser => _currentUser;
  
  /// Authentication status
  bool get isAuthenticated => _currentUser.isAuthenticated;
  
  /// RCP service instance
  final RcpService _rcpService = RcpService();
  
  /// Private constructor
  AuthService._internal();
  
  /// Login to the RCP server
  Future<User> login(String username, String password, {bool rememberMe = false}) async {
    try {
      // Connect to server first if not already connected
      if (!_rcpService.isConnected) {
        throw Exception('Not connected to server. Please connect first.');
      }
      
      // Use RCP service to authenticate
      final userData = await _rcpService.authenticate(username, password);
      
      // Create user from authentication response
      final user = User(
        id: userData['id'] as String? ?? userData['username'] as String,
        username: userData['username'] as String,
        displayName: userData['displayName'] as String?,
        email: userData['email'] as String?,
      );
      
      _currentUser = user;
      
      // Store credentials if remember me is enabled
      if (rememberMe) {
        await _storeCredentials(username, password);
      }
      
      return user;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get stored credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    final encodedCredentials = prefs.getString('credentials');
    if (encodedCredentials == null) return null;
    
    try {
      final credentialsJson = jsonDecode(encodedCredentials);
      return {
        'username': credentialsJson['username'] as String,
        'password': credentialsJson['password'] as String,
      };
    } catch (e) {
      await prefs.remove('credentials');
      return null;
    }
  }
  
  /// Check if stored credentials exist and try to authenticate with them
  Future<User?> checkStoredCredentials() async {
    final credentials = await getSavedCredentials();
    if (credentials == null) return null;
    
    try {
      return await login(
        credentials['username']!,
        credentials['password']!,
        rememberMe: true,
      );
    } catch (e) {
      print('Auto-login failed: $e');
      await clearCredentials();
      return null;
    }
  }
  
  /// Store credentials for auto-login
  Future<void> _storeCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    final credentials = {
      'username': username,
      'password': password,
    };
    
    await prefs.setString('credentials', jsonEncode(credentials));
  }
  
  /// Clear stored credentials
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('credentials');
  }
  
  /// Logout the current user
  Future<void> logout() async {
    try {
      await _rcpService.logout();
    } catch (e) {
      // Ignore errors during logout
      print('Error during logout: $e');
    } finally {
      _currentUser = User.guest();
    }
  }
}
