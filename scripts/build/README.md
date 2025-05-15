# RCP Client Build Scripts

This directory contains build scripts for the RCP Client Flutter application. These scripts handle the compilation process for different platforms.

## Available Scripts

- `build_rust_bridge.sh`: Builds the Rust FFI bridge for all supported platforms.
- `build_macos.sh`: Builds the macOS desktop application.
- `build_windows.sh`: Builds the Windows desktop application.
- `build_linux.sh`: Builds the Linux desktop application.
- `build_android.sh`: Builds the Android application.
- `build_ios.sh`: Builds the iOS application.
- `copy_native_libs.sh`: Copies native libraries to platform-specific locations.
- `setup_dev_environment.sh`: Sets up initial development environment.

## Usage

All scripts should be executed from the project root directory. For example:

```bash
./scripts/build/build_macos.sh
```

## Platform-specific Notes

### macOS
- Requires `Xcode` and the macOS SDK
- Rust targets: `x86_64-apple-darwin`, `aarch64-apple-darwin`

### Windows
- Requires Visual Studio build tools
- Rust target: `x86_64-pc-windows-msvc`

### Linux
- Requires GTK development libraries
- Rust target: `x86_64-unknown-linux-gnu`

### Android
- Requires Android SDK and NDK
- Uses `cargo-ndk` for building native libraries
- Rust targets: `aarch64-linux-android`, `armv7-linux-androideabi`, etc.

### iOS 
- Requires Xcode and iOS SDK
- Rust targets: `aarch64-apple-ios`, `x86_64-apple-ios`

## Common Issues

1. **Rust Bridge Directory Not Found**
   - The scripts will attempt to create the directory, but the bridge code must be properly set up.

2. **Native Libraries Missing**
   - Check that `copy_native_libs.sh` ran successfully and copied libraries to the right locations.

3. **CI Environment Issues**
   - The scripts detect CI environments and adjust settings accordingly.
   - Make sure environment variables are properly set.

## CI/CD Integration

These scripts are designed to work within the GitHub Actions workflows defined in `.github/workflows/`.

For more detailed information about the CI/CD process, refer to the `CI_CD_PROCESS.md` document in the project root.

## License

See the project LICENSE file for details.
