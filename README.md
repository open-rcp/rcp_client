# Flutter RCP Client

A cross-platform client for the Remote Computing Protocol (RCP) system, built using Flutter and Rust.

## Overview

The Flutter RCP Client is designed to replace the current SDL2/egui-based client with a more modern, cross-platform solution. It leverages Flutter's UI capabilities while integrating with the existing Rust-based RCP client libraries through Foreign Function Interface (FFI).

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
   cp rust/target/release/librcp_flutter_bridge.dylib macos/Runner/Frameworks/
   install_name_tool -id "@executable_path/../Frameworks/librcp_flutter_bridge.dylib" macos/Runner/Frameworks/librcp_flutter_bridge.dylib
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

## Project Structure

```
flutter_rcp_client/
├── lib/                 # Dart/Flutter code
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic
│   ├── utils/           # Utilities
│   └── widgets/         # Reusable widgets
├── rust/                # Rust FFI bridge
│   ├── src/             # Rust source code
│   └── Cargo.toml       # Rust dependencies
└── [platform folders]   # Platform-specific code
```

## Building and Running

### 1. Check Dependencies

Run the dependency check script to ensure all required components are installed:

```bash
./check_dependencies.sh
```

### 2. Build the Rust Library

Build the Rust FFI bridge library:

```bash
cd rust
cargo build --release
cd ..
```

### 3. Copy Native Libraries

For macOS:

```bash
./copy_macos_libs.sh
```

For other platforms, see the platform-specific instructions below.

### 4. Run the Application

```bash
flutter run
```

## Platform-Specific Instructions

### macOS

Ensure the Rust library is copied to the appropriate location:

```bash
mkdir -p macos/Runner/Frameworks
cp rust/target/release/librcp_flutter_bridge.dylib macos/Runner/Frameworks/
```

### iOS

The native library needs to be integrated as an iOS framework:

```bash
mkdir -p ios/Frameworks
cp rust/target/release/librcp_flutter_bridge.a ios/Frameworks/
```

### Android

For Android, the native library needs to be placed in the appropriate directories for each architecture:

```bash
mkdir -p android/app/src/main/jniLibs/arm64-v8a
cp rust/target/aarch64-linux-android/release/librcp_flutter_bridge.so android/app/src/main/jniLibs/arm64-v8a/
```

Repeat for other architectures (armeabi-v7a, x86, x86_64) as needed.

### Windows and Linux

Native libraries are typically loaded from the application's directory or a standard system location.

## Development Notes

- FFI bindings connect Flutter to the Rust RCP client libraries
- The application uses Provider for state management
- Use `flutter pub get` to update dependencies
- The `lib/utils/native_library.dart` helper handles platform-specific library loading

## Troubleshooting

If you encounter issues with FFI library loading:
1. Verify the Rust library is built correctly with `cargo build --release`
2. Ensure the library is copied to the correct platform-specific location
3. For issues with CocoaPods on macOS, try reinstalling CocoaPods
