#!/bin/bash

# Script to copy the Rust native library to the macOS app bundle
# This should be run after building the Rust library
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR"

# Source directory (Rust build output)
SOURCE_DIR="$ROOT_DIR/rust_bridge/target/release"
LIB_NAME="libflutter_rcp_bridge.dylib"
SOURCE_PATH="$SOURCE_DIR/$LIB_NAME"

# Alternative source from build directory
BUILD_NATIVE_DIR="$ROOT_DIR/build/native_assets/macos"
BUILD_SOURCE_PATH="$BUILD_NATIVE_DIR/$LIB_NAME"

# Destination directories for macOS
DEST_DIR="$ROOT_DIR/macos/Frameworks"
DEST_PATH="$DEST_DIR/$LIB_NAME"

# Additional target for debug/release build
BUILD_DIR="$ROOT_DIR/build/macos/Build/Products"
DEBUG_FRAMEWORKS="$BUILD_DIR/Debug/flutter_rcp_client.app/Contents/Frameworks"
RELEASE_FRAMEWORKS="$BUILD_DIR/Release/flutter_rcp_client.app/Contents/Frameworks"

# Check if the library exists in either location
if [ -f "$SOURCE_PATH" ]; then
    echo "Found library at: $SOURCE_PATH"
    ACTUAL_SOURCE=$SOURCE_PATH
elif [ -f "$BUILD_SOURCE_PATH" ]; then
    echo "Found library at: $BUILD_SOURCE_PATH"
    ACTUAL_SOURCE=$BUILD_SOURCE_PATH
else
    echo "ERROR: Native library not found at either:"
    echo "  - $SOURCE_PATH"
    echo "  - $BUILD_SOURCE_PATH"
    echo ""
    echo "Please build the Rust library first with:"
    echo "  ./build_rust_bridge.sh"
    exit 1
fi

# Create destination directories if they don't exist
mkdir -p "$DEST_DIR"

# Copy the library to the development location
echo "Copying $ACTUAL_SOURCE to $DEST_PATH"
cp "$ACTUAL_SOURCE" "$DEST_PATH"

# Update the install name for the macOS library
install_name_tool -id "@executable_path/../Frameworks/$LIB_NAME" "$DEST_PATH"

# Create the debug and release framework directories if they don't exist
mkdir -p "$DEBUG_FRAMEWORKS"
mkdir -p "$RELEASE_FRAMEWORKS"

# Copy to the built app
echo "Copying to debug build: $DEBUG_FRAMEWORKS/$LIB_NAME"
cp "$ACTUAL_SOURCE" "$DEBUG_FRAMEWORKS/$LIB_NAME"
install_name_tool -id "@executable_path/../Frameworks/$LIB_NAME" "$DEBUG_FRAMEWORKS/$LIB_NAME"

echo "Copying to release build: $RELEASE_FRAMEWORKS/$LIB_NAME"
cp "$ACTUAL_SOURCE" "$RELEASE_FRAMEWORKS/$LIB_NAME"
install_name_tool -id "@executable_path/../Frameworks/$LIB_NAME" "$RELEASE_FRAMEWORKS/$LIB_NAME"

# Add executable permission to the libraries
chmod +x "$DEST_PATH"
chmod +x "$DEBUG_FRAMEWORKS/$LIB_NAME"
chmod +x "$RELEASE_FRAMEWORKS/$LIB_NAME"

echo "Successfully copied native library for macOS"
