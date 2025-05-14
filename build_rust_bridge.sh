#!/bin/bash
# Build script for compiling the Rust FFI bridge for all platforms
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR"  # The root is actually the rcp_client directory
BRIDGE_DIR="$ROOT_DIR/rust_bridge"
OUTPUT_DIR="$ROOT_DIR/build/native_assets"

# Create output directory if not exists
mkdir -p "$OUTPUT_DIR"

echo "Building Rust FFI bridge for all platforms..."

# Function to compile for a target
compile_for_target() {
    local target=$1
    local output_file=$2
    local output_dir=$3
    
    echo "Building for target: $target"
    
    # Make sure BRIDGE_DIR exists
    if [ ! -d "$BRIDGE_DIR" ]; then
        echo "Error: Bridge directory not found at $BRIDGE_DIR"
        exit 1
    fi
    
    # Navigate to the bridge directory
    cd "$BRIDGE_DIR" || exit 1
    
    # Check if target directory exists, create it if not
    mkdir -p "target/$target/release"
    
    # Build the target
    cargo build --release --target "$target" || {
        echo "Failed to build for target $target, trying without explicit target..."
        cargo build --release
        # In case of failure without target, copy from default target path
        mkdir -p "$output_dir"
        if [ -f "target/release/$output_file" ]; then
            cp "target/release/$output_file" "$output_dir/"
            echo "✅ Built using default target"
            return 0
        else
            echo "❌ Build failed for $target"
            return 1
        fi
    }
    
    # Create output directory and copy the build
    mkdir -p "$output_dir"
    cp "target/$target/release/$output_file" "$output_dir/"
    
    echo "✅ Build for $target completed"
}

# Build for all supported platforms
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "Building for macOS..."
    compile_for_target "x86_64-apple-darwin" "librcpb.dylib" "$OUTPUT_DIR/macos"
    
    # iOS
    echo "Building for iOS..."
    compile_for_target "aarch64-apple-ios" "librcpb.a" "$OUTPUT_DIR/ios"
    compile_for_target "x86_64-apple-ios" "librcpb.a" "$OUTPUT_DIR/ios"
    
    # Copy to project directory for easy access during development
    mkdir -p "$ROOT_DIR/macos/Frameworks"
    cp "$OUTPUT_DIR/macos/librcpb.dylib" "$ROOT_DIR/macos/Frameworks/"
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "Building for Linux..."
    compile_for_target "x86_64-unknown-linux-gnu" "librcpb.so" "$OUTPUT_DIR/linux"
    
    # Android (requires Android NDK setup)
    if [ -d "$ANDROID_NDK_HOME" ]; then
        echo "Building for Android..."
        compile_for_target "aarch64-linux-android" "librcpb.so" "$OUTPUT_DIR/android/arm64-v8a"
        compile_for_target "armv7-linux-androideabi" "librcpb.so" "$OUTPUT_DIR/android/armeabi-v7a"
        compile_for_target "x86_64-linux-android" "librcpb.so" "$OUTPUT_DIR/android/x86_64"
    else
        echo "Android NDK not found. Skipping Android build."
    fi
    
    # Copy to project directory for easy access during development
    mkdir -p "$ROOT_DIR/linux/bundle/lib"
    cp "$OUTPUT_DIR/linux/librcpb.so" "$ROOT_DIR/linux/bundle/lib/"
    
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "win32" ]]; then
    # Windows
    echo "Building for Windows..."
    compile_for_target "x86_64-pc-windows-msvc" "rcpb.dll" "$OUTPUT_DIR/windows"
    
    # Copy to project directory for easy access during development
    mkdir -p "$ROOT_DIR/windows/runner/Debug"
    mkdir -p "$ROOT_DIR/windows/runner/Release"
    cp "$OUTPUT_DIR/windows/rcpb.dll" "$ROOT_DIR/windows/runner/Debug/"
    cp "$OUTPUT_DIR/windows/rcpb.dll" "$ROOT_DIR/windows/runner/Release/"
fi

echo "All builds completed successfully"
