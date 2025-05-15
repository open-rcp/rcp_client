# RCP Client

A cross-platform client for the Rust/Remote Control Protocol (RCP) system, built using Flutter and Rust with a dependency-free architecture.

![CI Status](https://github.com/open-rcp/rcp_client/actions/workflows/ci.yml/badge.svg)


## Overview

The RCP Client is designed to provide a modern, cross-platform solution for connecting to RCP servers. It leverages Flutter's UI capabilities while integrating with the Rust-based RCP client libraries through a dedicated Foreign Function Interface (FFI) bridge, ensuring clean separation of concerns and minimizing dependencies.

## Features

- Cross-platform support (macOS, Windows, Linux, iOS, Android)
- Server connection management
- User authentication
- Remote application discovery and launching
- Application streaming display
- Persistent settings

## Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.7.0 or newer)
- [Rust](https://www.rust-lang.org/tools/install) (version 1.70.0 or newer)

## Troubleshooting

### Native Library Issues

If you encounter a "Failed to initialize RCP service: Exception: Could not find native library" error:

1. Make sure you've built the Rust library in the correct location:
   ```bash
   cd rust
   cargo build --release --target-dir=./target
   cd ..
   ```

2. Copy the library to the platform-specific location:
   ```bash
   # For macOS:
   mkdir -p macos/Runner/Frameworks
   cp rust/target/release/librcp_bridge.dylib macos/Runner/Frameworks/
   install_name_tool -id "@executable_path/../Frameworks/librcp_bridge.dylib" macos/Runner/Frameworks/librcp_bridge.dylib
   ```

3. Check that the library paths in `lib/utils/native_library.dart` include the correct location for your development environment.

### macOS Sandbox Issues

If you encounter sandbox-related errors like "file system sandbox blocked open()" when running on macOS:

1. Make sure the Rust library is correctly placed in the `macos/Runner/Frameworks` directory
2. Verify that the entitlements files have the necessary permissions:
   - Check both `DebugProfile.entitlements` and `Release.entitlements`
   - Ensure they include `com.apple.security.cs.disable-library-validation` set to `true`
3. Clean the build and rebuild:
   ```bash
   flutter clean
   flutter build macos --debug
   flutter run -d macos
   ```

### CocoaPods Issues

If you encounter CocoaPods-related errors when building for macOS or iOS:

1. Reinstall CocoaPods:
   ```bash
   sudo gem uninstall cocoapods
   sudo gem install cocoapods
   ```

2. Clean the CocoaPods installation:
   ```bash
   cd ios # or cd macos
   pod deintegrate
   pod setup
   pod install
   cd ..
   ```
- For iOS/macOS: Xcode (version 14.0 or newer)
- For Android: Android Studio and NDK
- For Windows: Visual Studio with C++ build tools
- For Linux: Appropriate development packages

## Architecture

The Flutter RCP Client uses a clean architecture with a dedicated Rust FFI bridge:

1. **Flutter UI Layer** - Dart code for the user interface
2. **Service Layer** - Dart services that communicate with the Rust bridge
3. **FFI Bridge** - A dedicated Rust crate that exposes a clean API for the Flutter app
4. **RCP Core** - Core RCP functionality provided by Rust libraries

This architecture ensures the Flutter client remains dependency-free from other Rust projects except through the dedicated bridge.

## Project Structure

```
rcp_client/
├── lib/                 # Dart/Flutter code
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic and FFI bindings
│   ├── utils/           # Utilities
│   └── widgets/         # Reusable widgets
├── rust_bridge/         # Rust FFI bridge (new architecture)
│   ├── src/             # Rust source code
│   ├── Cargo.toml       # Rust dependencies
│   └── cbindgen.toml    # C binding configuration
├── scripts/            # Helper scripts
│   ├── build/          # Build-related scripts
│   │   ├── build_rust_bridge.sh  # Script to build the Rust bridge
│   │   ├── copy_native_libs.sh   # Script to copy native libraries
│   │   ├── build_macos.sh        # macOS build script
│   │   └── build_windows.sh      # Windows build script 
│   └── ci/             # CI-related scripts
│       ├── check_dependencies.sh # Dependency checker
│       └── setup_dev_environment.sh # Dev environment setup
└── [platform folders]   # Platform-specific code
```

## Building and Running

### 1. Check Dependencies

Run the dependency check script to ensure all required components are installed:

```bash
./scripts/ci/check_dependencies.sh
```

### 2. Build the Rust Bridge

Build the Rust FFI bridge library for your platform:

```zsh
chmod +x ./scripts/build/build_rust_bridge.sh
./scripts/build/build_rust_bridge.sh
```

### 3. Copy Native Libraries

Copy the native libraries to platform-specific locations:

```zsh
chmod +x ./scripts/build/copy_native_libs.sh
./scripts/build/copy_native_libs.sh
```

### 4. Migrate to New Architecture (Optional)

To update from the previous architecture to the dependency-free architecture:

```zsh
# If you need to migrate from legacy architecture (only for older installations)
chmod +x ./scripts/ci/migrate.sh
./scripts/ci/migrate.sh
```

This script backs up your files, makes necessary changes, and handles the migration process.

### 4. Run the Application

```bash
flutter run
```

## Platform-Specific Instructions

### macOS

For macOS, the library is automatically placed in the correct location by the `scripts/build/copy_native_libs.sh` script. If you need to manually place it:

```zsh
mkdir -p macos/Frameworks
cp build/native_assets/macos/librcpb.dylib macos/Frameworks/
```

### iOS

For iOS, the static library is embedded during the build process:

```zsh
mkdir -p ios/Frameworks
cp build/native_assets/ios/librcpb.a ios/Frameworks/
```

### Android

The `scripts/build/copy_native_libs.sh` script handles copying libraries for all architectures:

```zsh
# Libraries are automatically copied to:
# android/app/src/main/jniLibs/arm64-v8a/
# android/app/src/main/jniLibs/armeabi-v7a/
# android/app/src/main/jniLibs/x86_64/
```

### Windows and Linux

The script handles platform-specific paths for Windows (.dll) and Linux (.so) libraries as well.

## Development Notes

- The application uses a clean FFI bridge architecture that isolates the Flutter app from direct Rust dependencies
- Provider is used for state management throughout the application
- Use `flutter pub get` to update Flutter dependencies
- The `lib/services/rcp_bridge.dart` class handles FFI communication with the Rust code
- The `lib/utils/native_library_manager.dart` utility handles platform-specific library loading
- After changing Rust code, rebuild with `./scripts/build/build_rust_bridge.sh`

## Documentation

- [FFI_BRIDGE_DOCS.md](FFI_BRIDGE_DOCS.md) - Detailed documentation on the FFI bridge architecture
- [INTEGRATION.md](INTEGRATION.md) - Overview of the dependency-free integration approach
- [MIGRATION_PLAN.md](MIGRATION_PLAN.md) - Plan for migrating to the new architecture
- [NATIVE_LIBRARY_SETUP.md](NATIVE_LIBRARY_SETUP.md) - Instructions for setting up native libraries
- [rust_bridge/CBINDGEN_CONFIG_DOCS.md](rust_bridge/CBINDGEN_CONFIG_DOCS.md) - Documentation for cbindgen configuration
- [CI_CD_PROCESS.md](CI_CD_PROCESS.md) - CI/CD Process Documentation
- [.github/workflows/README.md](.github/workflows/README.md) - GitHub Actions workflows documentation

## Troubleshooting

If you encounter issues with FFI library loading:
1. Verify the Rust library is built correctly with `cargo build --release`
2. Ensure the library is copied to the correct platform-specific location
3. For issues with CocoaPods on macOS, try reinstalling CocoaPods
