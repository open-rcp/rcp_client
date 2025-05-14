# Flutter RCP Client FFI Bridge Documentation

This document provides comprehensive documentation for the Rust FFI Bridge used to ensure the Flutter RCP client is dependency-free from other Rust projects except through the dedicated bridge.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [FFI Bridge Components](#ffi-bridge-components)
3. [Configuration Files](#configuration-files)
4. [Implementation Details](#implementation-details)
5. [Usage in Flutter Code](#usage-in-flutter-code)
6. [Building and Deployment](#building-and-deployment)
7. [Troubleshooting](#troubleshooting)

## Architecture Overview

The Flutter RCP Client isolates itself from direct dependencies on the Rust workspace by utilizing a dedicated FFI (Foreign Function Interface) bridge. This architecture ensures:

- **Clean Separation**: Flutter code has no direct dependencies on Rust components
- **Dependency Isolation**: The Flutter app only depends on the bridge, not the entire Rust workspace
- **Simplified Interface**: Communication occurs through a well-defined API boundary
- **Independent Development**: Flutter and Rust teams can work independently

![Architecture Diagram](https://mermaid.ink/img/pako:eNp1kU1PwzAMhv9KlBNIbOpH27ETEmJCcODA5ZA6NS1NXCUulRD977iFrsAEuSTy4_jNa2egoTVQQHujnY27AbWxPZqPBVobeGxQkTFdWLP9EmltWq84rbM5ulabPhXVe4v55PaXt19cUVCcKhQb2gEf1jREJnxPj2AclrYTnqGSJDeGaBCWAyt1GG7xdEBIyDtQKxjBXU_xQzzkUmLQkSwU5D9b9tSN9VIDGN87bP9QKxRqDjtxBXkOxayl8amQEP9yx02cGhdOkijaBbNXbPQYEaOc29qEmXJpl0JyZUcXQl5e6jQ_x8smFLRzf8kkp1-frWsTw_4rnZ19AxpepUM)

## FFI Bridge Components

The bridge consists of several key components:

1. **Rust FFI Library** (`rust_bridge/`):
   - A dedicated crate that depends only on necessary Rust components
   - Exposes a C-compatible API for Flutter to consume
   - Handles memory management for cross-language communication

2. **Dart FFI Bindings** (`lib/services/rcp_bridge.dart`):
   - Maps Rust functions to Dart
   - Handles data conversion between languages
   - Provides a clean Dart API for the Flutter application

3. **Build Scripts**:
   - Compiles the Rust bridge for various platforms
   - Copies compiled libraries to appropriate platform-specific locations

## Configuration Files

### cbindgen.toml

The `cbindgen.toml` file configures C header generation from Rust code:

```toml
[defines]
"target_os = ios" = "TARGET_OS_IOS"
"target_os = macos" = "TARGET_OS_MACOS"
"target_os = android" = "TARGET_OS_ANDROID"
"target_os = windows" = "TARGET_OS_WINDOWS"
"target_os = linux" = "TARGET_OS_LINUX"

[export]
prefix = "RCP"
include = ["RcpResult", "RcpError", "AppInfo", "User"]

[export.rename]
"RcpResult" = "RcpResult"
"RcpError" = "RcpError"

[enum]
prefix_with_name = true
rename_variants = "ScreamingSnakeCase"
```

Key sections:

- **[defines]**: Platform-specific preprocessor definitions
- **[export]**: Configures exported types with "RCP" prefix
- **[export.rename]**: Explicitly renames specific types
- **[enum]**: Configures enum formatting in generated code

### Cargo.toml (rust_bridge)

```toml
[package]
name = "rcpb"
version = "0.1.0"
edition = "2021"

[lib]
name = "rcpb"
crate-type = ["cdylib", "staticlib"]

[dependencies]
# Core dependencies from workspace
rcpp = { path = "../../rcpp" }
rcpc = { path = "../../rcpc" }

# FFI support
ffi = "1.0"

# Only include necessary dependencies
tokio = { version = "1.35", features = ["rt"] }
anyhow = "1.0"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

[build-dependencies]
cbindgen = "0.26"
```

Key points:

- Uses both `cdylib` and `staticlib` for maximum platform compatibility
- Depends only on essential crates from the workspace
- Includes FFI-specific dependencies

## Implementation Details

### Rust FFI Interface

The Rust FFI bridge exposes several key functions with C-compatible types:

```rust
#[repr(C)]
pub struct RcpResult {
    success: bool,
    error_message: *mut c_char,
    data: *mut c_char,
}

#[no_mangle]
pub extern "C" fn rcp_init(host: *const c_char, port: i32) -> RcpResult;

#[no_mangle]
pub extern "C" fn rcp_authenticate(username: *const c_char, password: *const c_char) -> RcpResult;

#[no_mangle]
pub extern "C" fn rcp_get_available_apps() -> RcpResult;

#[no_mangle]
pub extern "C" fn rcp_launch_app(app_id: *const c_char) -> RcpResult;

#[no_mangle]
pub extern "C" fn rcp_logout() -> RcpResult;

#[no_mangle]
pub extern "C" fn rcp_free_result(result: RcpResult);
```

### Dart FFI Bindings

The Dart side defines corresponding structs and functions:

```dart
base class RcpResult extends Struct {
  @Bool()
  external bool success;
  
  external Pointer<Utf8> error_message;
  external Pointer<Utf8> data;
}

// FFI function signatures
typedef RcpInit = Pointer<RcpResult> Function(Pointer<Utf8>, int);
typedef RcpAuthenticate = Pointer<RcpResult> Function(Pointer<Utf8>, Pointer<Utf8>);
// ...etc
```

## Usage in Flutter Code

The bridge is used through service classes that abstract away the FFI details:

```dart
// RcpService provides a clean Dart API for the RCP functionality
class RcpService {
  final RcpBridge _bridge = RcpBridge();
  
  Future<bool> connect(String host, int port) async {
    final result = await _bridge.initConnection(host, port);
    return result['success'] as bool;
  }
  
  Future<List<AppInfo>> getAvailableApps() async {
    // Implementation uses the bridge
  }
  
  // ... other methods
}
```

## Building and Deployment

### Build Process

The build process involves:

1. Compiling the Rust code for target platforms:
   ```bash
   ./build_rust_bridge.sh
   ```

2. Copying libraries to platform-specific locations:
   ```bash
   ./copy_native_libs.sh
   ```

3. Building the Flutter application normally:
   ```bash
   flutter build <platform>
   ```

### Platform-Specific Considerations

#### iOS
- Libraries are statically linked
- Requires specific entitlements for JIT compilation

#### Android
- Libraries are placed in `jniLibs` directory per architecture
- Requires both ARM and x86 builds for emulator support

#### macOS/Windows/Linux
- Shared libraries are placed in platform-specific locations
- May require specific installation steps

## Troubleshooting

### Common Issues

1. **"Library not found" errors**:
   - Ensure libraries are compiled for the correct architecture
   - Verify libraries are in the correct platform-specific location

2. **Symbol resolution errors**:
   - Check that function signatures match between Rust and Dart
   - Ensure FFI data types are compatible

3. **Unexpected crashes**:
   - Check for memory management issues (forgotten `free` calls)
   - Add proper error handling on both Rust and Dart sides

4. **Performance issues**:
   - Minimize data copying between languages
   - Use bulk operations where possible instead of many small calls

### Debugging Tips

- Use `print` statements in Dart code to trace FFI calls
- Add logging in Rust code with environment variables to control verbosity
- Test FFI functions in isolation before integrating into the full app

---

This documentation should be updated as the bridge evolves to maintain an accurate reference.
