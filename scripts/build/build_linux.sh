#!/bin/bash
# Script to build the Flutter RCP Client for Linux
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"  # Navigate up to project root

echo "Building Flutter RCP Client for Linux..."
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

# Step 2: Build the Rust FFI bridge if needed
if [ -f "$SCRIPT_DIR/build_rust_bridge.sh" ]; then
    echo "Building Rust FFI bridge..."
    chmod +x "$SCRIPT_DIR/build_rust_bridge.sh"
    "$SCRIPT_DIR/build_rust_bridge.sh"
else
    echo "Warning: build_rust_bridge.sh not found. Skipping bridge build."
fi

# Step 3: Copy native libraries to the correct locations
if [ -f "$SCRIPT_DIR/copy_native_libs.sh" ]; then
    echo "Copying native libraries for Linux..."
    chmod +x "$SCRIPT_DIR/copy_native_libs.sh"
    "$SCRIPT_DIR/copy_native_libs.sh"
else
    echo "Warning: copy_native_libs.sh not found. Skipping library copy."
fi

# Step 4: Build the Flutter app for Linux
echo "Building Flutter app for Linux..."
cd "$ROOT_DIR"

# Check if we're in a CI environment
if [ ! -z "$CI" ] || [ ! -z "$GITHUB_ACTIONS" ]; then
    # In CI environment, use appropriate build settings
    flutter config --enable-linux-desktop
    flutter build linux --release
else
    # For local development
    flutter config --enable-linux-desktop
    flutter build linux --release
fi

# Step 5: Package the Linux build
echo "Packaging Linux build..."
OUTPUT_DIR="$ROOT_DIR/rcp-client-linux"
mkdir -p "$OUTPUT_DIR"

# Copy build files to output directory
cp -r "$ROOT_DIR/build/linux/x64/release/bundle/"* "$OUTPUT_DIR/"

# Add launcher script
cat > "$OUTPUT_DIR/launch.sh" << 'EOL'
#!/bin/bash
cd "$(dirname "$0")"
./rcp_client
EOL
chmod +x "$OUTPUT_DIR/launch.sh"

echo "Linux build completed successfully!"
echo "Output directory: $OUTPUT_DIR"
