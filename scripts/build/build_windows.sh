#!/bin/bash
# Script to build the Flutter RCP Client for Windows
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"  # Navigate up to project root

echo "Building Flutter RCP Client for Windows..."
echo "Project root directory: $ROOT_DIR"

# Create output directory
OUTPUT_DIR="$ROOT_DIR/rcp-client-windows"
mkdir -p "$OUTPUT_DIR"

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

# Step 2: Build the Rust FFI bridge with Windows target
echo "Building Rust FFI bridge for Windows..."
BUILD_WINDOWS=1 "$ROOT_DIR/build_rust_bridge.sh"

# Step 3: Build Flutter app for Windows
echo "Building Flutter app for Windows..."
flutter build windows --release

# Step 4: Copy artifacts to output directory
echo "Copying build artifacts to output directory..."
if [ -d "$ROOT_DIR/build/windows/runner/Release" ]; then
    cp -r "$ROOT_DIR/build/windows/runner/Release/"* "$OUTPUT_DIR/"
    echo "✅ Copied Windows build artifacts to $OUTPUT_DIR"
else
    echo "❌ Windows build directory not found at $ROOT_DIR/build/windows/runner/Release"
    exit 1
fi

echo "Windows build completed successfully"
