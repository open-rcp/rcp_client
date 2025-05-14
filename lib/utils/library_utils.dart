import 'dart:io';
import 'package:path/path.dart' as path;

import 'native_library.dart';

/// Utility class to help with native library setup
class LibraryUtils {
  /// Prepare native libraries before attempting to load them
  static Future<void> prepareNativeLibraries() async {
    if (Platform.isMacOS) {
      await _prepareMacOSLibraries();
    }
    // Add other platforms as needed
  }
  
  /// Prepare libraries for macOS
  static Future<void> _prepareMacOSLibraries() async {
    try {
      final libraryName = NativeLibrary.libraryName;
      
      // First, try to run the copy_macos_libs.sh script
      try {
        final scriptPath = path.join(Directory.current.path, 'copy_macos_libs.sh');
        if (File(scriptPath).existsSync()) {
          print('Running copy_macos_libs.sh script');
          final result = Process.runSync('sh', [scriptPath]);
          print(result.stdout);
          
          if (result.exitCode == 0) {
            print('Successfully ran copy_macos_libs.sh script');
            return; // Script succeeded, no need for manual copying
          } else {
            print('Warning: copy_macos_libs.sh script failed with exit code ${result.exitCode}');
            print('Error: ${result.stderr}');
            // Continue with manual copy as fallback
          }
        }
      } catch (e) {
        print('Error running copy_macos_libs.sh script: $e');
        // Continue with manual copy as fallback
      }
      
      // Source path (where the library is built)
      final rustTargetPath = path.join(
        Directory.current.path, 
        'rust', 
        'target', 
        'release', 
        libraryName
      );
      
      if (!File(rustTargetPath).existsSync()) {
        print('Warning: Native library not found at $rustTargetPath');
        print('Trying to find it in alternative locations...');
        
        // Try finding the library in alternative locations
        final alternatives = [
          path.join(Directory.current.path, 'macos', 'Runner', 'Frameworks', libraryName),
          '/Volumes/EXT/repos/open-rcp/rcp/rcp_client/rust/target/release/$libraryName',
          '/Volumes/EXT/repos/open-rcp/rcp/rcp_client/macos/Runner/Frameworks/$libraryName',
        ];
        
        bool found = false;
        for (final alt in alternatives) {
          if (File(alt).existsSync()) {
            print('Found library at alternative location: $alt');
            found = true;
            break;
          }
        }
        
        if (!found) {
          print('ERROR: Could not find native library in any location!');
          return;
        }
      }
      
      // Path in the app bundle
      final executable = Platform.resolvedExecutable;
      final bundleDir = path.dirname(path.dirname(executable));
      final frameworksDir = path.join(bundleDir, 'Frameworks');
      final frameworksPath = path.join(frameworksDir, libraryName);
      
      // Create Frameworks directory if it doesn't exist
      Directory(frameworksDir).createSync(recursive: true);
      
      if (File(rustTargetPath).existsSync()) {
        // Copy the library to the Frameworks directory
        print('Copying $rustTargetPath to $frameworksPath');
        File(rustTargetPath).copySync(frameworksPath);
        
        // Update the install name
        Process.runSync('install_name_tool', [
          '-id',
          '@executable_path/../Frameworks/$libraryName',
          frameworksPath
        ]);
        
        print('Successfully prepared native libraries for macOS');
      } else {
        print('WARNING: Could not find source library to copy');
      }
    } catch (e) {
      print('Error preparing native libraries: $e');
    }
  }
}
