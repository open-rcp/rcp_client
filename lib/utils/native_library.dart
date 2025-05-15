// filepath: /Volumes/EXT/repos/open-rcp/rcp/rcp_client/lib/utils/native_library.dart
import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Helper class for loading native libraries
class NativeLibrary {
  /// Get the native library name based on platform
  static String get libraryName {
    if (Platform.isWindows) {
      return 'rcp_bridge.dll';
    } else if (Platform.isMacOS) {
      return 'librcp_bridge.dylib';
    } else {
      return 'librcp_bridge.so';
    }
  }

  /// Load the dynamic library based on the current platform
  static Future<DynamicLibrary> load() async {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('librcp_bridge.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      // Get a list of possible locations
      final locations = await _getPossibleLibraryLocations();
      List<String> errors = [];

      // Log all attempted paths for debugging
      print('Attempting to load library from the following locations:');
      for (final location in locations) {
        print(' - $location');

        // Check if the file exists at this location
        if (!location.startsWith('@executable_path')) {
          final file = File(location);
          final exists = file.existsSync();
          print('   Exists: $exists');
        }
      }

      // First, try the standard executable path which should work with the sandbox
      try {
        print(
          "Trying to load from @executable_path/../Frameworks/$libraryName",
        );
        return DynamicLibrary.open(
          "@executable_path/../Frameworks/$libraryName",
        );
      } catch (e) {
        final error = "Failed to load from executable path: $e";
        print(error);
        errors.add(error);

        // Try to run the copy_macos_libs.sh script to fix the issue
        try {
          final result = Process.runSync('sh', [
            '-c',
            'cd "${Platform.environment['FLUTTER_APPLICATION_PATH'] ?? '.'}" && ./copy_macos_libs.sh',
          ]);
          print("Auto-copy script output: ${result.stdout}");
          print("Auto-copy script errors: ${result.stderr}");
        } catch (e) {
          print("Failed to run auto-copy script: $e");
        }
      }

      // Try other possible locations
      for (final location in locations) {
        if (location.startsWith('@executable_path')) {
          continue; // Already tried this one
        }

        try {
          final file = File(location);
          if (file.existsSync()) {
            print("Found library at $location, trying to load...");
            return DynamicLibrary.open(location);
          }
        } catch (e) {
          print("Failed to load from $location: $e");
          // Continue trying other locations
        }
      }

      // If we get here, we couldn't find the library
      throw Exception(
        'Failed to initialize RCP service: Could not load native library: $libraryName.\n\n'
        'To fix this issue, please try the following steps:\n'
        '1. Build the Rust library: cd rust_bridge && cargo build --release\n'
        '2. Run the copy script: ./copy_macos_libs.sh\n'
        '3. Clean and rebuild: flutter clean && flutter build macos --debug\n\n'
        'The library should be located at: build/macos/Build/Products/Debug/rcp_client.app/Contents/Frameworks/$libraryName',
      );
    } else {
      // Windows and Linux
      final locations = await _getPossibleLibraryLocations();

      // Try each location until we find the library
      for (final location in locations) {
        try {
          final file = File(location);
          if (file.existsSync()) {
            return DynamicLibrary.open(location);
          }
        } catch (e) {
          print("Failed to load from $location: $e");
          // Continue trying other locations
        }
      }

      throw Exception(
        'Could not find native library: $libraryName. '
        'Make sure to build it with cargo build --release',
      );
    }
  }

  /// Get possible locations for the native library
  static Future<List<String>> _getPossibleLibraryLocations() async {
    final result = <String>[];

    // For macOS, use the executable path which should work with sandbox restrictions
    if (Platform.isMacOS) {
      // These paths are accessible from the sandbox
      result.add('@executable_path/../Frameworks/$libraryName');
      result.add('@loader_path/../Frameworks/$libraryName');
      result.add('@rpath/$libraryName');

      // Get the path to the current executable's directory
      final executable = Platform.resolvedExecutable;
      final executableDir = path.dirname(executable);
      final bundleDir = path.dirname(path.dirname(executable));

      // Add bundle Frameworks directory (most likely to work)
      result.add(path.join(bundleDir, 'Frameworks', libraryName));
      result.add(path.join(executableDir, libraryName));
      result.add(path.join(bundleDir, 'MacOS', 'Frameworks', libraryName));
    }

    // Current project directory for development
    final appDir = await getApplicationDocumentsDirectory();
    final rootDir = appDir.parent.path;
    final projectPath = Directory.current.path;

    // Add project-specific paths for development
    result.add('$projectPath/macos/Runner/Frameworks/$libraryName');
    result.add(
      '$projectPath/build/macos/Build/Products/Debug/rcp_client.app/Contents/Frameworks/$libraryName',
    );
    result.add(
      '$projectPath/build/macos/Build/Products/Release/rcp_client.app/Contents/Frameworks/$libraryName',
    );
    result.add('$projectPath/rust/target/release/$libraryName');
    result.add('$projectPath/rust/target/debug/$libraryName');

    // Add standard development paths
    result.add(
      path.join(
        rootDir,
        'rcp_client',
        'macos',
        'Runner',
        'Frameworks',
        libraryName,
      ),
    );
    result.add(
      path.join(
        rootDir,
        'rcp_client',
        'rust',
        'target',
        'release',
        libraryName,
      ),
    );

    // Add platform-specific paths
    if (Platform.isMacOS) {
      final executable = Platform.resolvedExecutable;
      final bundleDir = path.dirname(path.dirname(executable));

      // Bundle Frameworks location
      result.add(path.join(bundleDir, 'Frameworks', libraryName));

      // Other possible macOS locations
      result.add(path.join(bundleDir, 'PlugIns', libraryName));
      result.add(path.join(path.dirname(executable), libraryName));
    } else if (Platform.isWindows) {
      final executable = Platform.resolvedExecutable;
      final exeDir = path.dirname(executable);

      result.add(path.join(exeDir, libraryName));
      result.add(path.join(exeDir, 'lib', libraryName));
    } else if (Platform.isLinux) {
      final executable = Platform.resolvedExecutable;
      final exeDir = path.dirname(executable);

      result.add(path.join(exeDir, 'lib', libraryName));
      result.add(path.join(exeDir, libraryName));

      // Standard Linux library locations
      result.add('/usr/lib/$libraryName');
      result.add('/usr/local/lib/$libraryName');
    }

    return result;
  }

  /// Copy the library from the build directory to the app bundle
  static Future<void> copyToBundle() async {
    // This would be used in a real implementation to copy the library to the bundle
    // during the build process
  }
}
