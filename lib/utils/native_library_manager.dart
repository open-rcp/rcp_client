import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Utility class for managing native library loading
class NativeLibraryManager {
  /// Check if libraries are present in expected locations
  static Future<bool> areLibrariesAvailable() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // On mobile, libraries are bundled with the app
      return true;
    }

    final libraryName = _getLibraryName();
    final libraryPath = await _getPlatformSpecificLibraryPath();

    final file = File(path.join(libraryPath, libraryName));
    return file.existsSync();
  }

  /// Copy libraries from asset bundle to app-specific directory
  static Future<void> prepareLibraries() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // On mobile, libraries are bundled with the app
      return;
    }

    // On desktop, we need to ensure the libraries are in the correct location
    try {
      final result = await Process.run('sh', [
        '-c',
        './copy_native_libs.sh',
      ], workingDirectory: path.dirname(Platform.resolvedExecutable));

      if (result.exitCode != 0) {
        debugPrint('Failed to copy native libraries: ${result.stderr}');
        throw Exception('Failed to prepare native libraries');
      }

      debugPrint('Native libraries prepared successfully');
    } catch (e) {
      debugPrint('Error preparing native libraries: $e');
      rethrow;
    }
  }

  /// Get the library name for the current platform
  static String _getLibraryName() {
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

  /// Get the platform-specific library path
  static Future<String> _getPlatformSpecificLibraryPath() async {
    if (Platform.isMacOS) {
      return path.join(
        path.dirname(Platform.resolvedExecutable),
        '../Frameworks',
      );
    } else if (Platform.isLinux) {
      return path.join(path.dirname(Platform.resolvedExecutable), 'lib');
    } else if (Platform.isWindows) {
      return path.dirname(Platform.resolvedExecutable);
    } else {
      final appDir = await getApplicationSupportDirectory();
      return path.join(appDir.path, 'libraries');
    }
  }
}
