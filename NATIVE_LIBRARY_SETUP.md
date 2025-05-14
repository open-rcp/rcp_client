# Native Library Setup for Flutter RCP Client

This document explains how to set up and troubleshoot the native Rust library that powers the Flutter RCP client.

## Building the Native Library

The Flutter RCP client uses a Rust FFI bridge to communicate with the RCP system. To build this library:

1. Make sure you have Rust installed on your system:
   ```
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. Navigate to the Rust library directory:
   ```
   cd /Volumes/EXT/repos/open-rcp/rcp/flutter_rcp_client/rust
   ```

3. Build the library:
   ```
   cargo build --release
   ```

4. Copy the library to the proper locations:
   ```
   cd ..
   ./copy_macos_libs.sh
   ```

## Troubleshooting

If you encounter library loading issues:

### "Failed to initialize RCP service: Could not find native library"

This error means the application can't locate the `librcp_flutter_bridge.dylib` file. Try these steps:

1. Ensure the Rust library is built:
   ```
   cd /Volumes/EXT/repos/open-rcp/rcp/flutter_rcp_client/rust
   cargo build --release
   ```

2. Run the copy script:
   ```
   cd ..
   ./copy_macos_libs.sh
   ```

3. Check if the library exists in the following locations:
   - `rust/target/release/librcp_flutter_bridge.dylib`
   - `macos/Runner/Frameworks/librcp_flutter_bridge.dylib`
   - `build/macos/Build/Products/Debug/flutter_rcp_client.app/Contents/Frameworks/librcp_flutter_bridge.dylib`

4. Clean and rebuild the Flutter app:
   ```
   flutter clean
   flutter build macos --debug
   ./copy_macos_libs.sh
   flutter run -d macos
   ```

### macOS Sandbox Issues

If you're seeing sandbox-related errors, check that:

1. The proper entitlements are set in:
   - `macos/Runner/DebugProfile.entitlements`
   - `macos/Runner/Release.entitlements`

2. Both files should include:
   ```xml
   <key>com.apple.security.cs.disable-library-validation</key>
   <true/>
   ```

## How the Library Loading Works

The application attempts to load the library in this order:

1. Try `@executable_path/../Frameworks/librcp_flutter_bridge.dylib` (macOS sandbox compatible)
2. Try paths from the list in `_getPossibleLibraryLocations()` in `native_library.dart`

When the app starts, it runs `LibraryUtils.prepareNativeLibraries()` to ensure the library is copied to all necessary locations.
