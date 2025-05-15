#!/bin/bash

# Script to check if all dependencies for the Flutter RCP client are installed

echo "Checking Flutter RCP Client dependencies..."
echo "=========================================="

# Check if Flutter is installed
echo -n "Checking Flutter... "
if command -v flutter &> /dev/null; then
    flutter_version=$(flutter --version | head -n 1)
    echo "✓ $flutter_version"
else
    echo "✗ Flutter not found. Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Rust is installed
echo -n "Checking Rust... "
if command -v rustc &> /dev/null; then
    rust_version=$(rustc --version)
    echo "✓ $rust_version"
else
    echo "✗ Rust not found. Please install Rust: https://www.rust-lang.org/tools/install"
    exit 1
fi

# Check if Cargo is installed
echo -n "Checking Cargo... "
if command -v cargo &> /dev/null; then
    cargo_version=$(cargo --version)
    echo "✓ $cargo_version"
else
    echo "✗ Cargo not found. Please install Rust: https://www.rust-lang.org/tools/install"
    exit 1
fi

# Check if the Rust library has been built
echo -n "Checking Rust RCP Bridge library... "
RUST_LIB_PATH="rust/target/release"
if [[ "$OSTYPE" == "darwin"* ]]; then
    RUST_LIB_FILE="$RUST_LIB_PATH/librcp_bridge.dylib"
elif [[ "$OSTYPE" == "linux"* ]]; then
    RUST_LIB_FILE="$RUST_LIB_PATH/librcp_bridge.so"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    RUST_LIB_FILE="$RUST_LIB_PATH/rcp_bridge.dll"
else
    echo "✗ Unknown OS type: $OSTYPE"
    exit 1
fi

if [ -f "$RUST_LIB_FILE" ]; then
    echo "✓ Found at $RUST_LIB_FILE"
else
    echo "✗ Not found at $RUST_LIB_FILE"
    echo "  Please build the Rust library by running: cd rust_bridge && cargo build --release"
    exit 1
fi

# Check Flutter dependencies
echo -n "Checking Flutter dependencies... "
flutter pub get > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ All dependencies installed"
else
    echo "✗ Failed to get Flutter dependencies"
    echo "  Please run: flutter pub get"
    exit 1
fi

# Check if macOS frameworks directory exists
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -n "Checking macOS Frameworks directory... "
    FRAMEWORKS_DIR="macos/Runner/Frameworks"
    if [ -d "$FRAMEWORKS_DIR" ]; then
        echo "✓ Found at $FRAMEWORKS_DIR"
    else
        echo "✗ Not found at $FRAMEWORKS_DIR"
        echo "  Please create the directory: mkdir -p $FRAMEWORKS_DIR"
        exit 1
    fi
    
    # Check if library is copied to Frameworks directory
    echo -n "Checking if Rust library is copied to Frameworks... "
    FRAMEWORK_LIB="$FRAMEWORKS_DIR/librcp_bridge.dylib"
    if [ -f "$FRAMEWORK_LIB" ]; then
        echo "✓ Found at $FRAMEWORK_LIB"
    else
        echo "✗ Not found at $FRAMEWORK_LIB"
        echo "  Please run the copy_macos_libs.sh script"
        exit 1
    fi
fi

echo "=========================================="
echo "All dependencies are correctly installed!"
echo "You can now run the Flutter RCP client with: flutter run"
