# RCP Client Release Process

This document outlines the process for creating and publishing new releases of the RCP Client Flutter application.

## Version Numbering

RCP Client follows [Semantic Versioning](https://semver.org/) (SemVer):

- **Major version (x)**: Incremented for incompatible API changes
- **Minor version (y)**: Incremented for backward-compatible feature additions
- **Patch version (z)**: Incremented for backward-compatible bug fixes

Example: `v1.2.3`

## Pre-Release Checklist

Before creating a new release:

1. Ensure all tests pass: `flutter test`
2. Update version number in `pubspec.yaml`
3. Update version number in Rust bridge code if necessary
4. Update CHANGELOG.md with all notable changes
5. Merge all planned changes into the main branch

## Creating a Release

### 1. Create and Push a Git Tag

The automated release process is triggered by pushing a tag with the version number:

```bash
# Replace x.y.z with the actual version numbers (e.g., 0.2.1)
git tag vx.y.z
git push origin vx.y.z
```

For example:
```bash
git tag v0.2.1
git push origin v0.2.1
```

This will automatically trigger the GitHub Actions release workflow.

### 2. Release Workflow

The GitHub Actions workflow will:

1. Create a new GitHub Release as a draft
2. Build the application for all platforms:
   - Android APK
   - iOS IPA (unsigned, for testing purposes)
   - macOS DMG
   - Windows ZIP
   - Linux TAR.GZ
3. Upload the build artifacts to the GitHub Release
4. Finalize the GitHub Release (changing it from draft to published)

### 3. Verify the Release

After the workflow completes:

1. Verify that all artifacts are properly uploaded to the GitHub Release
2. Check that the GitHub Release is no longer in draft state
3. Test the installed application on each platform to confirm it works correctly

## Manual Release (if needed)

If you need to manually create a release:

1. Create a new release from the GitHub web interface
2. Set the tag name to the version (e.g., `v0.2.1`)
3. Add release notes from the CHANGELOG.md
4. Upload the compiled binaries manually

## Platform-Specific Notes

### iOS Release

The GitHub Actions workflow creates an unsigned IPA for testing purposes. For production releases to the App Store:

1. Use a Mac with Xcode installed
2. Set up your Apple Developer account and certificates
3. Build the app using Flutter and Xcode
4. Upload to the App Store using Application Loader or Xcode

### Android Release

The APK built by the workflow can be used for direct distribution. For Google Play Store releases:

1. Sign the APK with your release key
2. Create an App Bundle: `flutter build appbundle --release`
3. Upload to the Google Play Console

## Hotfix Releases

For emergency fixes:

1. Create a hotfix branch from the tagged release
2. Make the necessary changes
3. Follow the standard release process with an incremented patch version

## Announcement

After a successful release:

1. Announce the new version in GitHub Discussions
2. Update documentation if necessary
3. Notify users through appropriate channels

---

For any questions about the release process, please contact the project maintainers.
