#!/bin/bash

# Script to copy the Rust native library to the macOS app bundle
# This should be run after building the Rust library

# Source directory (Rust build output)
SOURCE_DIR="rust/target/release"
LIB_NAME="librcp_flutter_bridge.dylib"
SOURCE_PATH="$SOURCE_DIR/$LIB_NAME"

# Destination directories for macOS
DEST_DIR="macos/Runner/Frameworks"
DEST_PATH="$DEST_DIR/$LIB_NAME"

# Additional target for debug/release build
BUILD_DIR="build/macos/Build/Products"
DEBUG_FRAMEWORKS="$BUILD_DIR/Debug/flutter_rcp_client.app/Contents/Frameworks"
RELEASE_FRAMEWORKS="$BUILD_DIR/Release/flutter_rcp_client.app/Contents/Frameworks"

# Check if the library exists
if [ ! -f "$SOURCE_PATH" ]; then
    echo "ERROR: Native library not found at $SOURCE_PATH"
    echo "Please build the Rust library first with:"
    echo "cd rust && cargo build --release"
    exit 1
fi

# Create destination directories if they don't exist
mkdir -p "$DEST_DIR"

# Copy the library to the development location
echo "Copying $SOURCE_PATH to $DEST_PATH"
cp "$SOURCE_PATH" "$DEST_PATH"

# Update the install name for the macOS library
install_name_tool -id "@executable_path/../Frameworks/$LIB_NAME" "$DEST_PATH"

# Create the debug and release framework directories if they don't exist
mkdir -p "$DEBUG_FRAMEWORKS"
mkdir -p "$RELEASE_FRAMEWORKS"

# Copy to the built app
echo "Copying to debug build: $DEBUG_FRAMEWORKS/$LIB_NAME"
cp "$SOURCE_PATH" "$DEBUG_FRAMEWORKS/$LIB_NAME"
install_name_tool -id "@executable_path/../Frameworks/$LIB_NAME" "$DEBUG_FRAMEWORKS/$LIB_NAME"

echo "Copying to release build: $RELEASE_FRAMEWORKS/$LIB_NAME"
cp "$SOURCE_PATH" "$RELEASE_FRAMEWORKS/$LIB_NAME"
install_name_tool -id "@executable_path/../Frameworks/$LIB_NAME" "$RELEASE_FRAMEWORKS/$LIB_NAME"

# Add executable permission to the libraries
chmod +x "$DEST_PATH"
chmod +x "$DEBUG_FRAMEWORKS/$LIB_NAME"
chmod +x "$RELEASE_FRAMEWORKS/$LIB_NAME"

echo "Successfully copied native library for macOS"
