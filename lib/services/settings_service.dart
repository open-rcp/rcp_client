import 'package:shared_preferences/shared_preferences.dart';

/// Settings service for managing application preferences
class SettingsService {
  /// Singleton instance
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  
  /// Private constructor
  SettingsService._internal();
  
  /// Default settings
  static const String _keyDefaultHost = 'settings_default_host';
  static const String _keyDefaultPort = 'settings_default_port';
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyRecentServers = 'settings_recent_servers';
  static const String _keyLogLevel = 'settings_log_level';
  
  /// Default values
  static const String defaultHost = 'localhost';
  static const int defaultPort = 8717;
  static const String defaultThemeMode = 'system'; // 'system', 'light', or 'dark'
  static const String defaultLogLevel = 'info'; // 'debug', 'info', 'warning', 'error'
  
  /// Load the default server host
  Future<String> getDefaultHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultHost) ?? defaultHost;
  }
  
  /// Save the default server host
  Future<void> setDefaultHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultHost, host);
  }
  
  /// Load the default server port
  Future<int> getDefaultPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDefaultPort) ?? defaultPort;
  }
  
  /// Save the default server port
  Future<void> setDefaultPort(int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultPort, port);
  }
  
  /// Load the theme mode preference
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? defaultThemeMode;
  }
  
  /// Save the theme mode preference
  Future<void> setThemeMode(String mode) async {
    assert(['system', 'light', 'dark'].contains(mode), 'Invalid theme mode');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }
  
  /// Load the list of recent servers
  Future<List<String>> getRecentServers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyRecentServers) ?? [];
  }
  
  /// Add a server to the list of recent servers
  Future<void> addRecentServer(String serverAddress) async {
    final prefs = await SharedPreferences.getInstance();
    final recentServers = prefs.getStringList(_keyRecentServers) ?? [];
    
    // Remove if already exists to avoid duplicates
    recentServers.remove(serverAddress);
    
    // Add to the beginning of the list
    recentServers.insert(0, serverAddress);
    
    // Limit the list size to 5 entries
    if (recentServers.length > 5) {
      recentServers.removeLast();
    }
    
    await prefs.setStringList(_keyRecentServers, recentServers);
  }
  
  /// Get the log level setting
  Future<String> getLogLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLogLevel) ?? defaultLogLevel;
  }
  
  /// Set the log level
  Future<void> setLogLevel(String level) async {
    assert(['debug', 'info', 'warning', 'error'].contains(level), 'Invalid log level');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLogLevel, level);
  }
  
  /// Clear all settings and restore defaults
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDefaultHost);
    await prefs.remove(_keyDefaultPort);
    await prefs.remove(_keyThemeMode);
    await prefs.remove(_keyRecentServers);
    await prefs.remove(_keyLogLevel);
  }
}
