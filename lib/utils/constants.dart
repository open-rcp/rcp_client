/// Constants used throughout the application
class AppConstants {
  /// Application name
  static const String appName = 'RCP Client';

  /// Application version
  static const String appVersion = '0.1.0';

  /// Default RCP server port
  static const int defaultServerPort = 8717;

  /// Server connection timeout in seconds
  static const int connectionTimeoutSeconds = 10;

  /// Authentication timeout in seconds
  static const int authTimeoutSeconds = 5;

  /// Minimum allowed port number
  static const int minPort = 1;

  /// Maximum allowed port number
  static const int maxPort = 65535;

  /// UI-related constants
  static const double appCardWidth = 180.0;
  static const double appCardHeight = 220.0;
  static const double appCardIconSize = 64.0;

  /// Regular expressions
  static final RegExp hostnameRegex = RegExp(
    r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$',
  );
  static final RegExp ipAddressRegex = RegExp(
    r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
  );
}
