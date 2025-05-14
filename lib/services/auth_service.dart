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
      // Use RCP service to authenticate
      final success = await _rcpService.authenticate(username, password);
      
      if (success) {
        // For now, create a basic user object
        _currentUser = User(
          id: username,  // Using username as ID temporarily
          username: username,
          displayName: username.split('@').first, // Simple display name
          token: _generateMockToken(username),
          rememberMe: rememberMe,
        );
        
        // Store credentials if remember me is enabled
        if (rememberMe) {
          await _saveCredentials(username, password);
        }
        
        return _currentUser;
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
  
  /// Logout the current user
  Future<void> logout() async {
    _currentUser = User.guest();
    
    // Clear remembered credentials if they exist
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_username');
    await prefs.remove('auth_password');
    await prefs.remove('auth_token');
  }
  
  /// Check for stored credentials and auto-login if available
  Future<User?> checkStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? username = prefs.getString('auth_username');
    final String? password = prefs.getString('auth_password');
    final String? token = prefs.getString('auth_token');
    
    // If we have stored credentials, try to use them
    if (username != null && password != null) {
      try {
        return await login(username, password, rememberMe: true);
      } catch (e) {
        // If auto-login fails, clear stored credentials
        await logout();
        return null;
      }
    }
    
    // No stored credentials or they were invalid
    return null;
  }
  
  /// Save user credentials for auto-login
  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_username', username);
    await prefs.setString('auth_password', password);
    await prefs.setString('auth_token', _currentUser.token ?? '');
  }
  
  /// Generate a mock authentication token (for testing)
  String _generateMockToken(String username) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$username:$timestamp';
    return base64Encode(utf8.encode(data));
  }
}
