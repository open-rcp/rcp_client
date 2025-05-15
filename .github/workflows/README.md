# GitHub Actions Workflows Documentation

This document provides an overview of the GitHub Actions workflows used in the RCP Client project.

## Overview of Workflows

1. **CI Workflow** (`ci.yml`): Continuous integration workflow for testing and building the Flutter and Rust components.
2. **Build and Release Workflow** (`build-release.yml`): Creates platform-specific releases for the RCP client.

## Workflow Directory Structure

```
.github/workflows/ - GitHub Actions workflow configuration files
└── scripts/ - Helper scripts specifically for GitHub Actions workflows

scripts/
├── build/ - Scripts for building the application
│   ├── build_macos.sh - macOS build script
│   ├── build_windows.sh - Windows build script
│   ├── build_rust_bridge.sh - Script for building the Rust FFI bridge
│   ├── copy_native_libs.sh - Script for copying native libraries
│   └── copy_macos_libs.sh - Script for copying macOS-specific libraries
└── ci/ - CI environment setup scripts
    ├── check_dependencies.sh - Script to check for required dependencies
    └── setup_dev_environment.sh - Developer environment setup script
```

## Key Workflow Features

### CI Workflow (`ci.yml`)

1. **Flutter Testing**:
   - Analyzes Flutter code with `flutter analyze`
   - Runs Flutter tests with `flutter test`

2. **Rust Bridge Building**:
   - Builds the Rust FFI bridge for communicating between Flutter and Rust
   - Uses intelligent caching to avoid rebuilding when possible
   - Uploads bridge artifacts for reuse in the release workflow

3. **Flutter Application Building**:
   - Builds the Flutter application for multiple platforms
   - Uses a matrix strategy for Linux and Windows builds

### Build and Release Workflow (`build-release.yml`)

1. **Version Management**:
   - Automatically detects version from Git tags
   - Supports manual version specification through workflow dispatch

2. **Rust Bridge Building**:
   - Reuses cached Rust bridge when available
   - Builds platform-specific libraries for Flutter

3. **Platform Builds**:
   - Creates platform-specific builds for macOS and Windows
   - Packages applications for distribution

4. **Release Creation**:
   - Generates changelog from Git commit history
   - Creates GitHub releases with appropriate artifacts
   - Groups changes by type (features, fixes, improvements)

## Best Practices

1. **Script Organization**:
   - All build scripts are located in the `scripts/build/` directory
   - CI-specific scripts are in the `scripts/ci/` directory

2. **Conventional Commits**:
   - Use conventional commit messages (`feat:`, `fix:`, etc.) for automatic changelog generation
   - Include scope when relevant (e.g., `fix(ui): repair login screen layout`)

3. **Workflow Optimization**:
   - Use caching to speed up builds
   - Skip unnecessary steps when possible
   - Upload artifacts only when needed

## Common Tasks

### Triggering a Release

1. Tag your commit with a version number: `git tag v1.0.0`
2. Push the tag: `git push origin v1.0.0`

The release workflow will automatically trigger, creating a new GitHub release.

### Manual Release Creation

1. Go to the "Actions" tab in the GitHub repository
2. Select the "Build and Release" workflow
3. Click "Run workflow"
4. Enter the desired version number (e.g., `v1.0.0`)
5. Click "Run workflow" to start the build process
