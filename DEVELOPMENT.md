# Flutter RCP Client Development Guide

This guide provides detailed instructions for setting up, building, and running the Flutter RCP client application with its dependency-free Rust FFI bridge.

## Project Architecture

The Flutter RCP client uses a dependency-free architecture where all Rust dependencies are isolated behind a dedicated FFI bridge. This architecture ensures:

1. The Flutter app depends only on the bridge, not the entire Rust workspace
2. Clean separation of concerns between Flutter and Rust components
3. Simplified interface through a well-defined API boundary

## Setup Instructions

### Prerequisites

- Flutter SDK (2.10.0 or later)
- Rust toolchain (stable channel)
- Cargo build tools
- For iOS/macOS: Xcode and Command Line Tools
- For Android: Android SDK and NDK
- For Windows: Visual Studio with C++ workload

### Initial Setup

1. Clone the RCP repository:
   ```bash
   git clone <repository-url>
   cd rcp
   ```

2. Run the setup script to configure the development environment:
   ```bash
   cd rcp_client
   chmod +x setup_dev_environment.sh
   ./setup_dev_environment.sh
   ```

3. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

## Building the Application

### Building for macOS

```bash
# Build everything at once with the convenience script
./build_macos.sh

# Or build step by step:
./build_rust_bridge.sh
./copy_macos_libs.sh
flutter build macos
```

### Building for Other Platforms

For other platforms, you need to:

1. Build the Rust bridge for your target platform:
   ```bash
   ./build_rust_bridge.sh
   ```

2. Copy the native libraries to the platform-specific location:
   ```bash
   ./copy_native_libs.sh
   ```

3. Build the Flutter app:
   ```bash
   flutter build <platform>
   ```

## Development Workflow

When making changes to the codebase:

1. **Rust Bridge Changes**: If you modify the Rust bridge interface, rebuild the bridge and update the Dart FFI bindings:
   ```bash
   ./build_rust_bridge.sh
   ```

2. **Flutter Code Changes**: Standard Flutter development process applies:
   ```bash
   flutter run -d <device>
   ```

3. **Testing Changes**: Run the test suite to ensure everything works:
   ```bash
   flutter test
   ```

## Troubleshooting

### Common Issues

1. **"Library not found" errors**:
   - Ensure libraries are compiled for the correct architecture
   - Verify libraries are in the correct platform-specific location
   - Check permissions on library files

2. **Symbol resolution errors**:
   - Check that function signatures match between Rust and Dart
   - Ensure FFI data types are compatible

3. **macOS app crashes on launch**:
   - Verify the library is correctly installed in the Frameworks directory
   - Check entitlements and permissions

4. **Android build fails**:
   - Verify NDK is properly set up
   - Check that libraries are built for all required architectures

## Architecture Documentation

For more details on the architecture design:

- See `FFI_BRIDGE_DOCS.md` for the bridge design
- See `CBINDGEN_EXPLAINED.md` for C binding generation
- See `NATIVE_LIBRARY_SETUP.md` for platform-specific library setup
