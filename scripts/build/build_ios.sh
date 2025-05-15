#!/bin/bash
# Script to build the Flutter RCP Client for iOS
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"  # Navigate up to project root

echo "Building Flutter RCP Client for iOS..."
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

# Step 2: Build the Rust FFI bridge for iOS
if [ -f "$SCRIPT_DIR/build_rust_bridge.sh" ]; then
    echo "Building Rust FFI bridge for iOS..."
    chmod +x "$SCRIPT_DIR/build_rust_bridge.sh"
    "$SCRIPT_DIR/build_rust_bridge.sh" ios
else
    echo "Warning: build_rust_bridge.sh not found. Skipping bridge build."
fi

# Step 3: Copy native libraries to the correct locations
if [ -f "$SCRIPT_DIR/copy_native_libs.sh" ]; then
    echo "Copying native libraries for iOS..."
    chmod +x "$SCRIPT_DIR/copy_native_libs.sh"
    "$SCRIPT_DIR/copy_native_libs.sh"
else
    echo "Warning: copy_native_libs.sh not found. Skipping library copy."
fi

# Step 4: Setup CocoaPods
echo "Setting up CocoaPods..."
cd "$ROOT_DIR/ios"
pod install

# Step 5: Build the Flutter app for iOS
echo "Building Flutter app for iOS..."
cd "$ROOT_DIR"

# Check if we're in a CI environment
if [ ! -z "$CI" ] || [ ! -z "$GITHUB_ACTIONS" ]; then
    # In CI environment, build without code signing
    flutter build ios --release --no-codesign
else
    # For local development, prompt for signing options
    echo "Building with development signing..."
    flutter build ios --release
fi

echo "iOS build completed successfully!"
echo "Output directory: $ROOT_DIR/build/ios/iphoneos/"
