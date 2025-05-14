#!/bin/bash
# Script to migrate Flutter RCP client to new architecture
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Starting migration to dependency-free architecture..."

# Step 1: Backup existing files
echo "Creating backups of existing files..."
cp "$SCRIPT_DIR/lib/services/rcp_service.dart" "$SCRIPT_DIR/lib/services/rcp_service.dart.bak"
cp "$SCRIPT_DIR/lib/services/auth_service.dart" "$SCRIPT_DIR/lib/services/auth_service.dart.bak"
cp "$SCRIPT_DIR/lib/main.dart" "$SCRIPT_DIR/lib/main.dart.bak"

# Step 2: Replace files
echo "Replacing files with new versions..."
if [ -f "$SCRIPT_DIR/lib/services/rcp_service_new.dart" ]; then
    mv "$SCRIPT_DIR/lib/services/rcp_service_new.dart" "$SCRIPT_DIR/lib/services/rcp_service.dart"
    echo "✅ Updated rcp_service.dart"
else
    echo "❌ rcp_service_new.dart not found. Skipping..."
fi

if [ -f "$SCRIPT_DIR/lib/services/auth_service_new.dart" ]; then
    mv "$SCRIPT_DIR/lib/services/auth_service_new.dart" "$SCRIPT_DIR/lib/services/auth_service.dart"
    echo "✅ Updated auth_service.dart"
else
    echo "❌ auth_service_new.dart not found. Skipping..."
fi

if [ -f "$SCRIPT_DIR/lib/main_new.dart" ]; then
    mv "$SCRIPT_DIR/lib/main_new.dart" "$SCRIPT_DIR/lib/main.dart"
    echo "✅ Updated main.dart"
else
    echo "❌ main_new.dart not found. Skipping..."
fi

# Step 3: Build the Rust bridge
echo "Building Rust bridge..."
if [ -f "$SCRIPT_DIR/build_rust_bridge.sh" ]; then
    chmod +x "$SCRIPT_DIR/build_rust_bridge.sh"
    "$SCRIPT_DIR/build_rust_bridge.sh"
    echo "✅ Built Rust bridge"
else
    echo "❌ build_rust_bridge.sh not found. Skipping..."
fi

# Step 4: Copy native libraries
echo "Copying native libraries..."
if [ -f "$SCRIPT_DIR/copy_native_libs.sh" ]; then
    chmod +x "$SCRIPT_DIR/copy_native_libs.sh"
    "$SCRIPT_DIR/copy_native_libs.sh"
    echo "✅ Copied native libraries"
else
    echo "❌ copy_native_libs.sh not found. Skipping..."
fi

# Step 5: Run flutter pub get to update dependencies
echo "Updating Flutter dependencies..."
flutter pub get
echo "✅ Updated Flutter dependencies"

echo "Migration completed successfully! Please test the application."
echo "If issues arise, you can restore from backups using restore_backup.sh"

# Create restore script
cat > "$SCRIPT_DIR/restore_backup.sh" << 'EOL'
#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Restoring from backups..."

for file in "$SCRIPT_DIR/lib/services/rcp_service.dart.bak" "$SCRIPT_DIR/lib/services/auth_service.dart.bak" "$SCRIPT_DIR/lib/main.dart.bak"; do
    if [ -f "$file" ]; then
        dest="${file%.bak}"
        cp "$file" "$dest"
        echo "✅ Restored $dest"
    else
        echo "❌ Backup not found: $file"
    fi
done

echo "Restoration complete."
EOL

chmod +x "$SCRIPT_DIR/restore_backup.sh"
echo "Created restore_backup.sh for rolling back if needed."
