#!/bin/bash
# Script to build the Flutter RCP Client for Android
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"  # Navigate up to project root

echo "Building Flutter RCP Client for Android..."
echo "Project root directory: $ROOT_DIR"

# Step 1: Ensure we have the bridge directory and necessary setup
if [ ! -d "$ROOT_DIR/rust_bridge" ]; then
    echo "Error: rust_bridge directory not found!"
    if [ -f "$SCRIPT_DIR/setup_dev_environment.sh" ]; then
        echo "Running setup_dev_environment.sh to create necessary directories..."
        chmod +x "$SCRIPT_DIR/setup_dev_environment.sh"
        "$SCRIPT_DIR/setup_dev_environment.sh"
    else
        mkdir -p "$ROOT_DIR/rust_bridge"
        echo "Created rust_bridge directory. Please ensure it's properly set up."
    fi
fi

# Step 2: Build the Rust FFI bridge for Android (usually handled in separate cargo-ndk step)
if [ -f "$SCRIPT_DIR/build_rust_bridge.sh" ]; then
    echo "Building Rust FFI bridge (default Android)..."
    chmod +x "$SCRIPT_DIR/build_rust_bridge.sh"
    "$SCRIPT_DIR/build_rust_bridge.sh" android
else
    echo "Warning: build_rust_bridge.sh not found. Skipping bridge build."
fi

# Step 3: Ensure JNI libraries are in the correct locations
echo "Checking Android JNI libraries..."
ANDROID_JNI_DIR="$ROOT_DIR/android/app/src/main/jniLibs"
mkdir -p "$ANDROID_JNI_DIR" 2>/dev/null || true

# Step 4: Build the Flutter app for Android
echo "Building Flutter app for Android..."
cd "$ROOT_DIR"

# For APKs
echo "Building APKs..."
flutter build apk --release --split-per-abi

# For App Bundle (optional)
echo "Building App Bundle..."
flutter build appbundle --release

echo "Android build completed successfully!"
echo "APK output directory: $ROOT_DIR/build/app/outputs/apk/release/"
echo "AAB output directory: $ROOT_DIR/build/app/outputs/bundle/release/"
