# Native Library Setup for Flutter RCP Client

This document explains how to set up and build the native Rust libraries required for the Flutter RCP Client application to function properly.

## Prerequisites

Before setting up the native libraries, ensure you have:

1. **Rust toolchain** installed (stable channel):
   ```zsh
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Flutter SDK** installed
3. **Platform-specific development tools** (Xcode for macOS/iOS, Android SDK, etc.)

## Building the Rust Bridge

The Flutter RCP client uses a dedicated Rust FFI bridge to communicate with the RCP system. To build this library:

1. Navigate to the Flutter RCP client directory:
   ```zsh
   cd /Volumes/EXT/repos/open-rcp/rcp/rcp_client
   ```

2. Run the build script to compile the Rust bridge for your platform:
   ```zsh
   chmod +x build_rust_bridge.sh
   ./build_rust_bridge.sh
   ```

3. Copy the compiled libraries to platform-specific locations:
   ```zsh
   chmod +x copy_native_libs.sh
   ./copy_native_libs.sh
   ```

## Directory Structure

The FFI bridge has the following structure:

```
rcp_client/
├── rust_bridge/           # Rust FFI bridge code
│   ├── Cargo.toml         # Dependencies and build configuration
│   ├── cbindgen.toml      # C binding generation config
│   ├── build.rs           # Build script for generating headers
│   └── src/
│       └── lib.rs         # Implementation of FFI functions
├── build_rust_bridge.sh   # Script to build for all platforms
└── copy_native_libs.sh    # Script to copy built libraries
```

## Troubleshooting

If you encounter library loading issues:

### "Failed to initialize RCP service: Could not find native library"

This error means the application can't locate the `librcpb.dylib` file. Try these steps:

1. Ensure the Rust bridge is built:
   ```zsh
   cd /Volumes/EXT/repos/open-rcp/rcp/rcp_client
   ./build_rust_bridge.sh
   ```

2. Run the copy script:
   ```zsh
   ./copy_native_libs.sh
   ```

3. Check if the library exists in the following locations:
   - `rust_bridge/target/release/librcpb.dylib`
   - `macos/Frameworks/librcpb.dylib`
   - `build/macos/Build/Products/Debug/rcp_client.app/Contents/Frameworks/librcpb.dylib`

4. Clean and rebuild the Flutter app:
   ```zsh
   flutter clean
   flutter build macos --debug
   ./copy_native_libs.sh
   flutter run -d macos
   ```
   
5. Use the automated migration script to resolve dependency issues:
   ```zsh
   chmod +x migrate.sh
   ./migrate.sh
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

The application uses a robust library loading mechanism:

1. First attempts to load from platform-specific standard locations:
   - macOS: `@executable_path/../Frameworks/librcpb.dylib`
   - iOS: Embedded in app bundle
   - Android: From appropriate `jniLibs` directory
   - Windows and Linux: From application directory

2. If that fails, it falls back to search in alternative locations defined in `NativeLibraryManager.dart`

The library uses a new architecture where the Flutter RCP client is dependency-free from other Rust projects except through the dedicated Rust bridge. This improves maintainability and simplifies cross-platform support.

## Platform-Specific Notes

### macOS

On macOS, the library is named `librcpb.dylib` and should be in `macos/Frameworks/`. 

To check if the library is properly loaded:

```zsh
otool -L macos/Frameworks/librcpb.dylib
```

### iOS

For iOS, static libraries are used and embedded in the app during the build process.

### Android

Android requires separate builds for each architecture (arm64-v8a, armeabi-v7a, x86_64).

## Documentation

For more detailed information, refer to:

- `FFI_BRIDGE_DOCS.md` - Complete documentation on the FFI bridge
- `rust_bridge/CBINDGEN_CONFIG_DOCS.md` - Documentation on cbindgen configuration
- `MIGRATION_PLAN.md` - Plan for migrating to the new architecture
