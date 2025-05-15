#!/bin/bash
# Setup script for Flutter and Rust environment in CI
# This centralizes common setup tasks to avoid duplication

set -e  # Exit immediately if a command exits with a non-zero status

# Log with timestamp
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Setting up Flutter and Rust environment for CI"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"

# Setup Flutter environment
setup_flutter() {
  log "Setting up Flutter..."
  log "Project root directory: $ROOT_DIR"
  
  # Make sure flutter path is available
  if ! command_exists flutter; then
    log "Flutter command not found in PATH"
    exit 1
  fi
  
  # Check Flutter version
  flutter --version
  
  # Enable relevant platforms based on current OS
  case "$(uname -s)" in
    Darwin*)  # macOS
      log "Enabling macOS and iOS desktop"
      flutter config --enable-macos-desktop
      ;;
    Linux*)   # Linux
      log "Enabling Linux desktop" 
      flutter config --enable-linux-desktop
      ;;
    MINGW*|MSYS_NT*)  # Windows
      log "Enabling Windows desktop"
      flutter config --enable-windows-desktop
      ;;
  esac
  
  # Clean to ensure no leftover build artifacts
  if [ "$1" = "clean" ]; then
    log "Cleaning Flutter project"
    flutter clean
  fi
  
  # Get dependencies
  log "Installing Flutter dependencies"
  flutter pub get
  
  log "Flutter setup complete"
}

# Setup Rust environment
setup_rust() {
  log "Setting up Rust environment..."
  
  # Make sure rustc and cargo are available
  if ! command_exists rustc || ! command_exists cargo; then
    log "Rust not found in PATH"
    exit 1
  fi
  
  # Check Rust version
  rustc --version
  cargo --version
  
  log "Rust setup complete"
}

# Setup platform specific dependencies
setup_platform_deps() {
  case "$(uname -s)" in
    Darwin*)  # macOS
      log "Setting up macOS-specific dependencies"
      # CocoaPods should be available in macOS runners
      if ! command_exists pod; then
        log "Installing CocoaPods"
        sudo gem install cocoapods
      fi
      ;;
    Linux*)   # Linux
      log "Setting up Linux-specific dependencies"
      # Linux dependencies are usually installed in the workflow directly
      ;;
    MINGW*|MSYS_NT*)  # Windows
      log "Setting up Windows-specific dependencies"
      # Windows dependencies are usually installed in the workflow directly
      ;;
  esac
}

# Main setup flow
main() {
  log "Starting environment setup"
  
  # Parse arguments
  CLEAN_FLAG=""
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --clean) CLEAN_FLAG="clean"; shift ;;
      *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
  done
  
  setup_platform_deps
  setup_flutter "$CLEAN_FLAG"
  setup_rust
  
  log "Environment setup complete"
}

# Run main function with all arguments
main "$@"
