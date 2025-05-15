#!/bin/bash
# Script to copy compiled native libraries to platform-specific locations
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR"  # The root is actually the rcp_client directory
NATIVE_DIR="$ROOT_DIR/build/native_assets"

echo "Copying compiled libraries to platform-specific locations..."

# macOS
if [ -f "$NATIVE_DIR/macos/librcpb.dylib" ]; then
    mkdir -p "$ROOT_DIR/macos/Frameworks"
    cp "$NATIVE_DIR/macos/librcpb.dylib" "$ROOT_DIR/macos/Frameworks/"
    echo "✅ Copied macOS library"
fi

# iOS (embedded in app bundle during build)
if [ -d "$NATIVE_DIR/ios" ]; then
    mkdir -p "$ROOT_DIR/ios/Frameworks"
    cp -r "$NATIVE_DIR/ios/"*.a "$ROOT_DIR/ios/Frameworks/"
    echo "✅ Copied iOS libraries"
fi

# Linux
if [ -f "$NATIVE_DIR/linux/librcpb.so" ]; then
    mkdir -p "$ROOT_DIR/linux/bundle/lib"
    cp "$NATIVE_DIR/linux/librcpb.so" "$ROOT_DIR/linux/bundle/lib/"
    echo "✅ Copied Linux library"
fi

# Android
if [ -d "$NATIVE_DIR/android" ]; then
    mkdir -p "$ROOT_DIR/android/app/src/main/jniLibs/arm64-v8a"
    mkdir -p "$ROOT_DIR/android/app/src/main/jniLibs/armeabi-v7a"
    mkdir -p "$ROOT_DIR/android/app/src/main/jniLibs/x86_64"
    
    if [ -f "$NATIVE_DIR/android/arm64-v8a/librcpb.so" ]; then
        cp "$NATIVE_DIR/android/arm64-v8a/librcpb.so" "$ROOT_DIR/android/app/src/main/jniLibs/arm64-v8a/"
    fi
    
    if [ -f "$NATIVE_DIR/android/armeabi-v7a/librcpb.so" ]; then
        cp "$NATIVE_DIR/android/armeabi-v7a/librcpb.so" "$ROOT_DIR/android/app/src/main/jniLibs/armeabi-v7a/"
    fi
    
    if [ -f "$NATIVE_DIR/android/x86_64/librcpb.so" ]; then
        cp "$NATIVE_DIR/android/x86_64/librcpb.so" "$ROOT_DIR/android/app/src/main/jniLibs/x86_64/"
    fi
    
    echo "✅ Copied Android libraries"
fi

# Windows
if [ -f "$NATIVE_DIR/windows/rcpb.dll" ]; then
    mkdir -p "$ROOT_DIR/windows/runner/Debug"
    mkdir -p "$ROOT_DIR/windows/runner/Release"
    cp "$NATIVE_DIR/windows/rcpb.dll" "$ROOT_DIR/windows/runner/Debug/"
    cp "$NATIVE_DIR/windows/rcpb.dll" "$ROOT_DIR/windows/runner/Release/"
    echo "✅ Copied Windows library"
fi

echo "All libraries copied successfully"
