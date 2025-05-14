# CI/CD Process for RCP Client

This document explains the Continuous Integration (CI) and Continuous Deployment (CD) process for the RCP Client Flutter application.

## Overview

The RCP Client uses GitHub Actions to automate building, testing, and releasing the application across multiple platforms.

## Workflow Structure

### 1. CI Workflow (`ci.yml`)

The CI workflow runs on every push to the main/master branch and pull requests to ensure code quality and build integrity.

#### Jobs:

1. **Flutter Tests**: Runs Flutter's test suite and analyzer
2. **Build Rust Bridge**: Compiles the native Rust bridge code and runs Clippy checks
3. **Build Android**: Builds the Android APK
4. **Build iOS**: Builds the iOS app (without signing)
5. **Build macOS**: Compiles the macOS application
6. **Build Windows**: Compiles the Windows application
7. **Build Linux**: Compiles the Linux application

### 2. Release Workflow (`release.yml`)

The release workflow is triggered when a tag with the `v*` pattern is pushed (e.g., `v1.0.0`) or manually through the workflow dispatch feature.

#### Jobs:

1. **Create Release**: Creates a draft GitHub release
2. **Build platforms**: Separate jobs for building Android, iOS, macOS, Windows, and Linux
3. **Upload artifacts**: Uploads each platform's binary to the GitHub release

### 3. Changelog Workflow (`changelog.yml`)

This workflow automatically generates and updates the `CHANGELOG.md` file based on commit messages.

#### Features:

- Categorizes changes based on commit prefixes (feat, fix, etc.)
- Creates pull requests for manual releases
- Commits directly for automated releases

## Rust Bridge

The Rust bridge is a critical component that connects Flutter with our Rust core libraries. The build process handles:

1. Cross-compilation for multiple platforms
2. Fallback mechanisms for unavailable targets (important for CI)
3. Generation of platform-specific libraries

### Building the Rust Bridge

The `build_rust_bridge.sh` script handles compiling the Rust code for all required platforms:

```bash
./build_rust_bridge.sh
```

This script is called during CI builds and can be run locally during development.

## Release Process

See [RELEASE.md](./RELEASE.md) for a detailed explanation of the release process.

### Quick Steps:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` (or run the changelog workflow)
3. Push a tag with the version number: `git tag v1.2.3 && git push origin v1.2.3`
4. Wait for the release workflow to complete
5. Review and publish the draft release

## Troubleshooting

### Common Issues:

1. **Rust target missing**: Install the required target with `rustup target add <target-triple>`
2. **Flutter version mismatch**: Ensure CI uses the same Flutter version as required in pubspec.yaml
3. **Rust bridge build failures**: Try building with `./build_rust_bridge.sh` locally to debug

### Log Access:

All build logs are available in the "Actions" tab of the GitHub repository.

## Maintenance

The CI/CD workflows should be regularly updated to:

1. Keep Flutter and Dart versions current
2. Ensure Rust compilation targets are available
3. Update build tools and dependencies

---

For questions or support with the CI/CD process, please contact the project maintainers.
