import 'package:flutter/foundation.dart';
import 'app_info.dart';
import 'user.dart';

/// Application state model for managing global application state
class AppState extends ChangeNotifier {
  /// Connection state
  bool _connected = false;
  bool get connected => _connected;

  /// Authentication state
  bool _authenticated = false;
  bool get authenticated => _authenticated;

  /// Server connection information
  String _host = 'localhost';
  int _port = 8717;
  String get host => _host;
  int get port => _port;

  /// User information
  User _user = User.guest();
  User get user => _user;

  /// Available applications
  List<AppInfo> _apps = [];
  List<AppInfo> get apps => List.unmodifiable(_apps);

  /// Currently active application
  String? _activeAppId;
  String? get activeAppId => _activeAppId;
  AppInfo? get activeApp =>
      _activeAppId == null
          ? null
          : _apps.firstWhere(
            (app) => app.id == _activeAppId,
            orElse:
                () => throw Exception('Active app not found: $_activeAppId'),
          );

  /// Error message (null if no error)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Loading state indicator
  bool _loading = false;
  bool get loading => _loading;

  /// Constructor with default values
  AppState();

  /// Update connection state
  void setConnected(bool value) {
    _connected = value;
    if (!value) {
      // Reset authentication when disconnected
      _authenticated = false;
      _user = User.guest();
      _apps = [];
      _activeAppId = null;
    }
    notifyListeners();
  }

  /// Update server connection information
  void setServerInfo(String host, int port) {
    _host = host;
    _port = port;
    notifyListeners();
  }

  /// Update authentication state and user information
  void setAuthenticated(bool value, {User? user}) {
    _authenticated = value;
    if (value && user != null) {
      _user = user;
    } else if (!value) {
      _user = User.guest();
      _apps = [];
      _activeAppId = null;
    }
    notifyListeners();
  }

  /// Update available applications
  void setApps(List<AppInfo> apps) {
    _apps = List.from(apps);
    notifyListeners();
  }

  /// Set active application by ID
  void setActiveApp(String? appId) {
    _activeAppId = appId;
    notifyListeners();
  }

  /// Set error message
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Clear authentication and reset to initial state
  void logout() {
    _authenticated = false;
    _user = User.guest();
    _apps = [];
    _activeAppId = null;
    notifyListeners();
  }

  /// Update a specific application in the list
  void updateApp(AppInfo updatedApp) {
    final index = _apps.indexWhere((app) => app.id == updatedApp.id);
    if (index >= 0) {
      _apps[index] = updatedApp;
      notifyListeners();
    }
  }
}
