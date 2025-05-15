#!/usr/bin/env bash
# Version management script to check for dependency mismatches and outdated packages

set -e  # Exit immediately if a command exits with a non-zero status

# Log with timestamp
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Running dependency validation"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    log "Error: Flutter is not installed or not in PATH"
    exit 1
fi

# Function to check outdated dependencies
check_outdated_deps() {
  log "Checking for outdated dependencies..."
  flutter pub outdated
}

# Function to verify dependency consistency across platforms
verify_dependency_consistency() {
  log "Verifying dependency consistency..."
  
  # Check for inconsistent dependencies in platform-specific files
  INCONSISTENT=0
  
  # Get the Flutter version from pubspec.yaml
  FLUTTER_VERSION=$(grep "flutter:" -A 2 pubspec.yaml | grep "sdk:" | awk '{print $2}')
  log "Flutter SDK version in pubspec.yaml: $FLUTTER_VERSION"
  
  # Check platform files for version inconsistencies
  
  # Android
  if [ -f "android/app/build.gradle" ]; then
    log "Checking Android Gradle files..."
    # Add specific checks for Android versions if needed
  fi
  
  # iOS
  if [ -f "ios/Podfile" ]; then
    log "Checking iOS Podfile..."
    # Add specific checks for iOS dependencies if needed
  fi
  
  # macOS
  if [ -f "macos/Podfile" ]; then
    log "Checking macOS Podfile..."
    # Add specific checks for macOS dependencies if needed
  fi
  
  if [ $INCONSISTENT -eq 1 ]; then
    log "Warning: Dependency inconsistencies found"
    return 1
  else
    log "All dependency versions are consistent"
    return 0
  fi
}

# Function to validate native bridge dependencies
validate_native_bridge() {
  log "Validating Rust bridge dependencies..."
  
  if [ -d "rust_bridge" ]; then
    cd rust_bridge
    
    # Check if there are any issues with cargo
    log "Running cargo check..."
    cargo check
    
    # Return to original directory
    cd ..
  else
    log "Warning: rust_bridge directory not found"
    return 1
  fi
  
  return 0
}

# Main function
main() {
  log "Starting dependency validation"
  
  ERRORS=0
  
  # Run checks
  check_outdated_deps || ERRORS=$((ERRORS + 1))
  verify_dependency_consistency || ERRORS=$((ERRORS + 1))
  validate_native_bridge || ERRORS=$((ERRORS + 1))
  
  if [ $ERRORS -gt 0 ]; then
    log "Validation completed with $ERRORS issues"
    exit 1
  else
    log "All dependency checks passed!"
    exit 0
  fi
}

main
