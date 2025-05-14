#!/bin/bash
# Script to build the Flutter RCP Client for macOS
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR"

echo "Building Flutter RCP Client for macOS..."

# Step 1: Ensure we have the bridge directory and necessary setup
if [ ! -d "$ROOT_DIR/rust_bridge" ]; then
    echo "Error: rust_bridge directory not found!"
    echo "Running setup_dev_environment.sh to create necessary directories..."
    "$ROOT_DIR/setup_dev_environment.sh"
fi

# Step 2: Build the Rust FFI bridge
echo "Building Rust FFI bridge..."
"$ROOT_DIR/build_rust_bridge.sh"

# Step 3: Copy native libraries to the correct locations
echo "Copying native libraries for macOS..."
"$ROOT_DIR/copy_macos_libs.sh"

# Step 4: Build the Flutter app for macOS
echo "Building Flutter app for macOS..."
cd "$ROOT_DIR"
flutter build macos --release

echo "✅ Flutter RCP Client build for macOS completed!"
echo ""
echo "You can now run the app with:"
echo "open build/macos/Build/Products/Release/flutter_rcp_client.app"
