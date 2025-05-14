# Flutter RCP Client

A Flutter-based cross-platform client for the Remote Computing Protocol (RCP).

## Architecture Overview

This Flutter client uses a dedicated Rust FFI bridge to communicate with the RCP infrastructure. This design ensures:

1. **Dependency Isolation**: The Flutter app is dependency-free from other Rust projects in the workspace except for the dedicated bridge.
2. **Clean Integration**: The Rust FFI bridge serves as the sole integration point between Flutter and the RCP ecosystem.
3. **Cross-Platform Support**: Works on all major platforms (iOS, Android, macOS, Windows, Linux) with a single codebase.

## Project Structure

```
rcp_client/
├── android/              # Android platform code
├── ios/                  # iOS platform code  
├── lib/                  # Dart/Flutter code
├── linux/                # Linux platform code
├── macos/                # macOS platform code
├── windows/              # Windows platform code
├── rust_bridge/          # Dedicated Rust FFI bridge
│   ├── Cargo.toml        # Rust dependencies
│   ├── build.rs          # Build script for header generation
│   └── src/
│       └── lib.rs        # FFI implementation
└── build_rust_bridge.sh  # Script to compile Rust for all platforms
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.7.x or higher)
- Dart SDK (3.0.x or higher)
- Rust toolchain (stable channel)
- For iOS/macOS: Xcode
- For Android: Android SDK and NDK
- For Windows: Visual Studio with C++ support
- For Linux: gcc and required libraries

### Building the Project

1. **Compile the Rust FFI bridge**:

   ```bash
   cd rcp_client
   ./build_rust_bridge.sh
   ```

2. **Copy native libraries to platform folders**:

   ```bash
   ./copy_native_libs.sh
   ```

3. **Build the Flutter app**:

   ```bash
   flutter pub get
   flutter build <platform>
   ```

   Replace `<platform>` with one of: `ios`, `android`, `macos`, `windows`, `linux`

## Development

### Adding New FFI Functions

1. Add the function in `rust_bridge/src/lib.rs`
2. Rebuild using `./build_rust_bridge.sh`
3. Update the corresponding Dart FFI code in `lib/services/rcp_bridge.dart`

### Architecture Guidelines

- Keep the Flutter app and Rust bridge independent of each other's implementation details
- All communication must go through well-defined FFI interfaces
- Avoid circular dependencies between projects
- Use proper error handling on both Rust and Dart sides

## Deployment

When deploying the application, ensure the Rust bridge library is:

1. Compiled for all target architectures
2. Properly bundled with the app package
3. Available at the correct location in the app bundle

For platform-specific distribution instructions, please refer to the Flutter documentation.

## Dependencies

The Rust bridge only depends on:
- `rcpp`
- `rcpc`

This ensures the Flutter client remains isolated from implementation details of other components in the RCP ecosystem.
