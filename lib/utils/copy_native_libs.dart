/// Script to copy native libraries to the appropriate locations in the Flutter app
/// This script should be run as part of the build process for each platform

import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  // Determine the platform
  final String platform = _getPlatform();
  final String libName = _getLibraryName(platform);
  
  // Source path (Rust build output)
  final String sourceDir = path.join('rust', 'target', 'release');
  final String sourcePath = path.join(sourceDir, libName);
  
  // Check if the library exists
  if (!File(sourcePath).existsSync()) {
    print('ERROR: Native library not found at $sourcePath');
    print('Please build the Rust library first with:');
    print('cd rust && cargo build --release');
    exit(1);
  }
  
  // Destination path based on platform
  final String destPath = _getDestinationPath(platform, libName);
  
  // Create destination directory if it doesn't exist
  final destDir = path.dirname(destPath);
  Directory(destDir).createSync(recursive: true);
  
  // Copy the library
  print('Copying $sourcePath to $destPath');
  File(sourcePath).copySync(destPath);
  print('Successfully copied native library for $platform');
  
  // For macOS, we need to set the correct rpath
  if (platform == 'macos') {
    _updateMacOSRPath(destPath);
  }
}

String _getPlatform() {
  if (Platform.isWindows) return 'windows';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isLinux) return 'linux';
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  throw UnsupportedError('Unsupported platform');
}

String _getLibraryName(String platform) {
  switch (platform) {
    case 'windows':
      return 'rcp_bridge.dll';
    case 'macos':
      return 'librcp_bridge.dylib';
    case 'linux':
    case 'android':
    case 'ios':
      return 'librcp_bridge.so';
    default:
      throw UnsupportedError('Unsupported platform: $platform');
  }
}

String _getDestinationPath(String platform, String libName) {
  switch (platform) {
    case 'macos':
      return path.join('macos', 'Runner', 'Frameworks', libName);
    case 'windows':
      return path.join('windows', 'runner', 'Release', libName);
    case 'linux':
      return path.join('linux', 'bundle', 'lib', libName);
    case 'android':
      // For Android, we need to copy to multiple architecture directories
      // This is a simplified example - in practice, you'd need to build for each arch
      return path.join('android', 'app', 'src', 'main', 'jniLibs', 'arm64-v8a', libName);
    case 'ios':
      return path.join('ios', 'Frameworks', libName);
    default:
      throw UnsupportedError('Unsupported platform: $platform');
  }
}

void _updateMacOSRPath(String libraryPath) {
  // For macOS, use install_name_tool to update the library's rpath
  try {
    final result = Process.runSync('install_name_tool', [
      '-id',
      '@executable_path/../Frameworks/${path.basename(libraryPath)}',
      libraryPath
    ]);
    
    if (result.exitCode != 0) {
      print('WARNING: Failed to update rpath for macOS library:');
      print(result.stderr);
    }
  } catch (e) {
    print('WARNING: Failed to run install_name_tool: $e');
  }
}
