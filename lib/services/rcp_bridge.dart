import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// RcpResult struct from the Rust FFI bridge
base class RcpResult extends Struct {
  @Bool()
  external bool success;

  external Pointer<Utf8> errorMessage;
  external Pointer<Utf8> data;
}

/// FFI binding to the Rust bridge for RCP client
class RcpBridge {
  static DynamicLibrary? _dylib;

  // FFI function types
  late final RcpInit _rcpInit;
  late final RcpAuthenticate _rcpAuthenticate;
  late final RcpGetAvailableApps _rcpGetAvailableApps;
  late final RcpLaunchApp _rcpLaunchApp;
  late final RcpLogout _rcpLogout;
  late final RcpFreeResult _rcpFreeResult;

  // Singleton pattern
  static final RcpBridge _instance = RcpBridge._internal();
  factory RcpBridge() => _instance;

  RcpBridge._internal() {
    _loadLibrary();
    _bindFunctions();
  }

  /// Load the dynamic library for the current platform
  Future<void> _loadLibrary() async {
    if (_dylib != null) return;

    final libraryName = _getLibraryName();
    final libraryPath = await _getLibraryPath(libraryName);

    try {
      _dylib = DynamicLibrary.open(libraryPath);
      print('RCP bridge library loaded successfully from: $libraryPath');
    } catch (e) {
      print('Failed to load RCP bridge library: $e');
      rethrow;
    }
  }

  /// Get the library name for the current platform
  String _getLibraryName() {
    if (Platform.isWindows) {
      return 'rcpb.dll';
    } else if (Platform.isMacOS) {
      return 'librcpb.dylib';
    } else if (Platform.isLinux) {
      return 'librcpb.so';
    } else if (Platform.isAndroid) {
      return 'librcpb.so';
    } else if (Platform.isIOS) {
      return 'rcpb.framework/rcpb';
    } else {
      throw UnsupportedError(
        'Unsupported platform: ${Platform.operatingSystem}',
      );
    }
  }

  /// Get the full path to the library
  Future<String> _getLibraryPath(String libraryName) async {
    if (Platform.isAndroid) {
      // On Android, libraries are bundled with the app
      return libraryName;
    } else if (Platform.isMacOS) {
      // On macOS, the library is in the Frameworks directory at app bundle root
      return path.join(
        DynamicLibrary.executable()
            .toString()
            .split('/')
            .sublist(0, 5)
            .join('/'),
        'Frameworks',
        libraryName,
      );
    }

    // For other desktop platforms, we'll use the app's directory
    final appDir = await getApplicationSupportDirectory();
    return path.join(appDir.path, 'libraries', libraryName);
  }

  /// Bind Rust FFI functions
  void _bindFunctions() {
    if (_dylib == null) {
      throw StateError('RCP bridge library not loaded');
    }

    _rcpInit = _dylib!.lookupFunction<
      Pointer<RcpResult> Function(Pointer<Utf8>, Int32),
      Pointer<RcpResult> Function(Pointer<Utf8>, int)
    >('rcp_init');

    _rcpAuthenticate = _dylib!.lookupFunction<
      Pointer<RcpResult> Function(Pointer<Utf8>, Pointer<Utf8>),
      Pointer<RcpResult> Function(Pointer<Utf8>, Pointer<Utf8>)
    >('rcp_authenticate');

    _rcpGetAvailableApps = _dylib!.lookupFunction<
      Pointer<RcpResult> Function(),
      Pointer<RcpResult> Function()
    >('rcp_get_available_apps');

    _rcpLaunchApp = _dylib!.lookupFunction<
      Pointer<RcpResult> Function(Pointer<Utf8>),
      Pointer<RcpResult> Function(Pointer<Utf8>)
    >('rcp_launch_app');

    _rcpLogout = _dylib!.lookupFunction<
      Pointer<RcpResult> Function(),
      Pointer<RcpResult> Function()
    >('rcp_logout');

    _rcpFreeResult = _dylib!.lookupFunction<
      Void Function(Pointer<RcpResult>),
      void Function(Pointer<RcpResult>)
    >('rcp_free_result');
  }

  /// Initialize the RCP client connection
  Future<Map<String, dynamic>> initConnection(String host, int port) async {
    final hostUtf8 = host.toNativeUtf8();

    try {
      final result = _rcpInit(hostUtf8, port);
      return _processResult(result);
    } finally {
      calloc.free(hostUtf8);
    }
  }

  /// Authenticate a user
  Future<Map<String, dynamic>> authenticate(
    String username,
    String password,
  ) async {
    final usernameUtf8 = username.toNativeUtf8();
    final passwordUtf8 = password.toNativeUtf8();

    try {
      final result = _rcpAuthenticate(usernameUtf8, passwordUtf8);
      return _processResult(result);
    } finally {
      calloc.free(usernameUtf8);
      calloc.free(passwordUtf8);
    }
  }

  /// Get available applications
  Future<Map<String, dynamic>> getAvailableApps() async {
    final result = _rcpGetAvailableApps();
    return _processResult(result);
  }

  /// Launch an application
  Future<Map<String, dynamic>> launchApp(String appId) async {
    final appIdUtf8 = appId.toNativeUtf8();

    try {
      final result = _rcpLaunchApp(appIdUtf8);
      return _processResult(result);
    } finally {
      calloc.free(appIdUtf8);
    }
  }

  /// Logout the current user
  Future<Map<String, dynamic>> logout() async {
    final result = _rcpLogout();
    return _processResult(result);
  }

  /// Process an RcpResult into a Dart map
  Map<String, dynamic> _processResult(Pointer<RcpResult> resultPtr) {
    final result = resultPtr.ref;

    try {
      final response = <String, dynamic>{'success': result.success};

      if (result.errorMessage != Pointer<Utf8>.fromAddress(0)) {
        response['error'] = result.errorMessage.toDartString();
      }

      if (result.data != Pointer<Utf8>.fromAddress(0)) {
        response['data'] = result.data.toDartString();
      }

      return response;
    } finally {
      _rcpFreeResult(resultPtr);
    }
  }
}

// FFI function signatures
typedef RcpInit = Pointer<RcpResult> Function(Pointer<Utf8>, int);
typedef RcpAuthenticate =
    Pointer<RcpResult> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef RcpGetAvailableApps = Pointer<RcpResult> Function();
typedef RcpLaunchApp = Pointer<RcpResult> Function(Pointer<Utf8>);
typedef RcpLogout = Pointer<RcpResult> Function();
typedef RcpFreeResult = void Function(Pointer<RcpResult>);
