#!/bin/bash
# Script to set up the development environment for RCP Client

set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"

echo "Setting up development environment for RCP Client..."

# Ensure required directories exist
mkdir -p "$ROOT_DIR/rust_bridge" 2>/dev/null || true
mkdir -p "$ROOT_DIR/build/native_assets/macos" 2>/dev/null || true

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed or not in PATH"
    echo "Please install Flutter and try again"
    exit 1
fi

# Check if Rust is installed
if ! command -v rustc &> /dev/null; then
    echo "Rust is not installed or not in PATH"
    echo "Please install Rust and try again"
    exit 1
fi

# Get or update Flutter dependencies
echo "Getting Flutter dependencies..."
cd "$ROOT_DIR"
flutter pub get

echo "Development environment setup complete!"
