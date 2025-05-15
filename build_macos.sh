#!/bin/bash
# Script to build the Flutter RCP Client for macOS
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR"

# Detect if running in CI environment
if [ ! -z "$CI" ] || [ ! -z "$GITHUB_ACTIONS" ]; then
    IS_CI=1
    echo "CI environment detected, adjusting build settings..."
else
    IS_CI=0
fi

echo "Building Flutter RCP Client for macOS..."

# Step 1: Setup CI environment if needed
if [ "$IS_CI" = "1" ] && [ -f "$ROOT_DIR/ci/setup_ci.sh" ]; then
    echo "Setting up CI environment..."
    chmod +x "$ROOT_DIR/ci/setup_ci.sh"
    "$ROOT_DIR/ci/setup_ci.sh"
fi

# Step 2: Ensure we have the bridge directory and necessary setup
if [ ! -d "$ROOT_DIR/rust_bridge" ]; then
    echo "Error: rust_bridge directory not found!"
    echo "Running setup_dev_environment.sh to create necessary directories..."
    "$ROOT_DIR/setup_dev_environment.sh"
fi

# Step 3: Build the Rust FFI bridge
echo "Building Rust FFI bridge..."
"$ROOT_DIR/build_rust_bridge.sh"

# Step 4: Copy native libraries to the correct locations
echo "Copying native libraries for macOS..."
"$ROOT_DIR/copy_macos_libs.sh"

# Step 5: Build the Flutter app for macOS
echo "Building Flutter app for macOS..."
cd "$ROOT_DIR"

# Use different build arguments depending on environment
if [ "$IS_CI" = "1" ]; then
    flutter config --no-analytics
    flutter build macos --release --no-codesign
else
    flutter build macos --release
fi

echo "✅ Flutter RCP Client build for macOS completed!"
if [ "$IS_CI" = "0" ]; then
    echo ""
    echo "You can now run the app with:"
    echo "open build/macos/Build/Products/Release/rcp_client.app"
fi
