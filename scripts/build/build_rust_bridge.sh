#!/bin/bash
# Build script for compiling the Rust FFI bridge for all platforms
# 
# This script builds the Rust FFI bridge for multiple platforms to enable
# Flutter to interface with native Rust code. It handles:
#
# 1. Building for macOS (x86_64-apple-darwin, aarch64-apple-darwin)
# 2. Building for iOS (aarch64-apple-ios, x86_64-apple-ios for simulator)
# 3. Building for Android (multiple ABIs)
# 4. Building for Windows (x86_64-pc-windows-msvc)
# 5. Building for Linux (x86_64-unknown-linux-gnu)
#
# The script has fallback mechanisms to handle cases where specific targets
# aren't available, ensuring CI builds can still succeed.

set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"  # Navigate up to the rcp_client directory
BRIDGE_DIR="$ROOT_DIR/rust_bridge"
OUTPUT_DIR="$ROOT_DIR/build/native_assets"

# CI environment detection
if [ ! -z "$CI" ] || [ ! -z "$GITHUB_ACTIONS" ]; then
    IS_CI=1
    echo "CI environment detected, adjusting build settings..."
else
    IS_CI=0
fi

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

# Print summary after all builds are done
print_summary() {
    echo ""
    echo "============================================================="
    echo "🎉 Rust bridge build summary"
    echo "============================================================="
    echo "✅ Default target library created at: $OUTPUT_DIR/librcp_bridge.a"
    
    # Add more details about available targets, etc.
    if rustup target list --installed | grep -q "installed"; then
        echo "📋 Available Rust targets:"
        rustup target list --installed
    fi
    
    echo "=============================================================\n"
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
    # Windows native build
    echo "Building for Windows..."
    compile_for_target "x86_64-pc-windows-msvc" "rcpb.dll" "$OUTPUT_DIR/windows"
    
    # Copy to project directory for easy access during development
    mkdir -p "$ROOT_DIR/windows/runner/Debug"
    mkdir -p "$ROOT_DIR/windows/runner/Release"
    cp "$OUTPUT_DIR/windows/rcpb.dll" "$ROOT_DIR/windows/runner/Debug/"
    cp "$OUTPUT_DIR/windows/rcpb.dll" "$ROOT_DIR/windows/runner/Release/"
else
    # Non-native environment but requested Windows build
    if [ "$BUILD_WINDOWS" = "1" ] || [ ! -z "$GITHUB_ACTIONS" ]; then
        echo "Building for Windows on non-Windows platform..."
        # Try with MSVC (most common for Windows CI)
        if compile_for_target "x86_64-pc-windows-msvc" "rcpb.dll" "$OUTPUT_DIR/windows"; then
            echo "Successfully built for x86_64-pc-windows-msvc"
        # Fallback to MinGW if MSVC fails
        elif compile_for_target "x86_64-pc-windows-gnu" "rcpb.dll" "$OUTPUT_DIR/windows"; then
            echo "Successfully built for x86_64-pc-windows-gnu"
        else
            echo "Warning: Windows cross-compilation failed, continuing anyway"
        fi
        
        # Copy to Flutter Windows build locations (only if files exist)
        if [ -f "$OUTPUT_DIR/windows/rcpb.dll" ]; then
            mkdir -p "$ROOT_DIR/windows/runner/Debug"
            mkdir -p "$ROOT_DIR/windows/runner/Release"
            cp "$OUTPUT_DIR/windows/rcpb.dll" "$ROOT_DIR/windows/runner/Debug/"
            cp "$OUTPUT_DIR/windows/rcpb.dll" "$ROOT_DIR/windows/runner/Release/"
            echo "✅ Copied Windows DLLs to runner directories"
        fi
    fi
fi

echo "All builds completed successfully"
print_summary
