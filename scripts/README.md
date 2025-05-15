# RCP Client Scripts

This directory contains scripts organized by purpose for the RCP Client project.

## Directory Structure

```
scripts/
├── build/                   # Build-specific scripts
│   ├── build_macos.sh       # macOS build script
│   ├── build_windows.sh     # Windows build script
│   ├── build_rust_bridge.sh # Script for building the Rust FFI bridge
│   ├── copy_native_libs.sh  # Script for copying native libraries
│   └── copy_macos_libs.sh   # Script for copying macOS-specific libraries
└── ci/                      # CI-specific scripts
    ├── check_dependencies.sh # Script to check for required dependencies
    └── setup_dev_environment.sh # Developer environment setup script
```

## Usage

### Build Scripts

These scripts are used to build the application and its components for different platforms.

- **build_rust_bridge.sh**: Builds the Rust bridge FFI library
  ```bash
  ./scripts/build/build_rust_bridge.sh
  ```

- **build_macos.sh**: Builds the macOS application
  ```bash
  ./scripts/build/build_macos.sh
  ```

- **build_windows.sh**: Builds the Windows application
  ```bash
  ./scripts/build/build_windows.sh
  ```

- **copy_native_libs.sh**: Copies native libraries to the appropriate locations
  ```bash
  ./scripts/build/copy_native_libs.sh
  ```

### CI Scripts

These scripts are used in CI environments or for setting up development environments.

- **check_dependencies.sh**: Checks if all required dependencies are installed
  ```bash
  ./scripts/ci/check_dependencies.sh
  ```

- **setup_dev_environment.sh**: Sets up a development environment
  ```bash
  ./scripts/ci/setup_dev_environment.sh
  ```

## CI/CD Integration

These scripts are called from GitHub Actions workflows defined in `.github/workflows/`. See the [workflow documentation](../.github/workflows/README.md) for more details.
