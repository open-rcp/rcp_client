#!/bin/bash
# Setup script for Flutter RCP Client dependency-free architecture
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Setting up Flutter RCP Client development environment..."

# Step 1: Verify directory structure
echo "Verifying directory structure..."

# Check rust_bridge directory
if [ ! -d "$SCRIPT_DIR/rust_bridge" ]; then
    echo "Creating rust_bridge directory..."
    mkdir -p "$SCRIPT_DIR/rust_bridge/src"
fi

# Check if Cargo.toml exists
if [ ! -f "$SCRIPT_DIR/rust_bridge/Cargo.toml" ]; then
    echo "Creating Cargo.toml..."
    cat > "$SCRIPT_DIR/rust_bridge/Cargo.toml" << 'EOL'
[package]
name = "flutter_rcp_bridge"
version = "0.1.0"
edition = "2021"

[lib]
name = "flutter_rcp_bridge"
crate-type = ["cdylib", "staticlib"]

[dependencies]
# Core dependencies from workspace
rcp-core = { path = "../../rcp-core" }
rcp-client = { path = "../../rcp-client" }

# FFI support
ffi = "1.0"

# Only include necessary dependencies
tokio = { version = "1.35", features = ["rt"] }
anyhow = "1.0"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

[build-dependencies]
cbindgen = "0.26"
EOL
fi

# Check if cbindgen.toml exists
if [ ! -f "$SCRIPT_DIR/rust_bridge/cbindgen.toml" ]; then
    echo "Creating cbindgen.toml..."
    cat > "$SCRIPT_DIR/rust_bridge/cbindgen.toml" << 'EOL'
[defines]
"target_os = ios" = "TARGET_OS_IOS"
"target_os = macos" = "TARGET_OS_MACOS"
"target_os = android" = "TARGET_OS_ANDROID"
"target_os = windows" = "TARGET_OS_WINDOWS"
"target_os = linux" = "TARGET_OS_LINUX"

[export]
prefix = "RCP"
include = ["RcpResult", "RcpError", "AppInfo", "User"]

[export.rename]
"RcpResult" = "RcpResult"
"RcpError" = "RcpError"

[enum]
prefix_with_name = true
rename_variants = "ScreamingSnakeCase"
EOL
fi

# Check if build.rs exists
if [ ! -f "$SCRIPT_DIR/rust_bridge/build.rs" ]; then
    echo "Creating build.rs..."
    cat > "$SCRIPT_DIR/rust_bridge/build.rs" << 'EOL'
fn main() {
    let crate_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let config = cbindgen::Config::from_file("cbindgen.toml").unwrap_or_default();
    
    cbindgen::Builder::new()
        .with_crate(crate_dir)
        .with_config(config)
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file("bindings.h");

    // Platform-specific compilation flags
    #[cfg(target_os = "ios")]
    {
        println!("cargo:rustc-link-lib=framework=Security");
        println!("cargo:rustc-link-lib=framework=Foundation");
    }

    #[cfg(target_os = "macos")]
    {
        println!("cargo:rustc-link-lib=framework=Security");
        println!("cargo:rustc-link-lib=framework=Foundation");
    }
}
EOL
fi

# Check if lib.rs exists
if [ ! -f "$SCRIPT_DIR/rust_bridge/src/lib.rs" ]; then
    echo "Creating lib.rs..."
    cat > "$SCRIPT_DIR/rust_bridge/src/lib.rs" << 'EOL'
use std::ffi::{c_char, CStr, CString};
use std::ptr;
use std::sync::Arc;

#[derive(Debug)]
#[repr(C)]
pub struct RcpResult {
    success: bool,
    error_message: *mut c_char,
    data: *mut c_char,
}

#[derive(Debug)]
#[repr(C)]
pub struct User {
    username: *mut c_char,
    display_name: *mut c_char,
    email: *mut c_char,
}

#[derive(Debug)]
#[repr(C)]
pub struct AppInfo {
    id: *mut c_char,
    name: *mut c_char,
    description: *mut c_char,
    icon_url: *mut c_char,
}

// Helper function to create a C string from Rust string
fn to_c_string(s: String) -> *mut c_char {
    match CString::new(s) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

// Helper function to get Rust string from C string
fn from_c_string(s: *const c_char) -> Result<String, String> {
    if s.is_null() {
        return Err("Null pointer provided".to_string());
    }
    
    unsafe {
        CStr::from_ptr(s)
            .to_str()
            .map(|s| s.to_string())
            .map_err(|e| format!("Invalid UTF-8: {}", e))
    }
}

// Helper function to create a result object
fn create_result(success: bool, error_message: Option<String>, data: Option<String>) -> RcpResult {
    RcpResult {
        success,
        error_message: error_message.map_or(ptr::null_mut(), |e| to_c_string(e)),
        data: data.map_or(ptr::null_mut(), |d| to_c_string(d)),
    }
}

// Free memory allocated for RcpResult
#[no_mangle]
pub extern "C" fn rcp_free_result(result: RcpResult) {
    unsafe {
        if !result.error_message.is_null() {
            let _ = CString::from_raw(result.error_message);
        }
        if !result.data.is_null() {
            let _ = CString::from_raw(result.data);
        }
    }
}

// Free memory allocated for User
#[no_mangle]
pub extern "C" fn rcp_free_user(user: User) {
    unsafe {
        if !user.username.is_null() {
            let _ = CString::from_raw(user.username);
        }
        if !user.display_name.is_null() {
            let _ = CString::from_raw(user.display_name);
        }
        if !user.email.is_null() {
            let _ = CString::from_raw(user.email);
        }
    }
}

// Free memory allocated for AppInfo
#[no_mangle]
pub extern "C" fn rcp_free_app_info(app: AppInfo) {
    unsafe {
        if !app.id.is_null() {
            let _ = CString::from_raw(app.id);
        }
        if !app.name.is_null() {
            let _ = CString::from_raw(app.name);
        }
        if !app.description.is_null() {
            let _ = CString::from_raw(app.description);
        }
        if !app.icon_url.is_null() {
            let _ = CString::from_raw(app.icon_url);
        }
    }
}

// Initialize the RCP client
#[no_mangle]
pub extern "C" fn rcp_init(host: *const c_char, port: i32) -> RcpResult {
    let host_str = match from_c_string(host) {
        Ok(s) => s,
        Err(e) => return create_result(false, Some(e), None),
    };
    
    // Mock implementation (replace with actual RCP client initialization)
    create_result(true, None, None)
}

// Authenticate a user
#[no_mangle]
pub extern "C" fn rcp_authenticate(username: *const c_char, password: *const c_char) -> RcpResult {
    let username_str = match from_c_string(username) {
        Ok(s) => s,
        Err(e) => return create_result(false, Some(e), None),
    };
    
    let password_str = match from_c_string(password) {
        Ok(s) => s,
        Err(e) => return create_result(false, Some(e), None),
    };
    
    // Mock successful authentication
    let user_json = format!(r#"{{
        "id": "user-123",
        "username": "{}",
        "displayName": "Test User",
        "email": "{}@example.com"
    }}"#, username_str, username_str);
    
    create_result(true, None, Some(user_json))
}

// Get available applications
#[no_mangle]
pub extern "C" fn rcp_get_available_apps() -> RcpResult {
    // Mock apps data
    let apps_json = r#"[
        {
            "id": "app1",
            "name": "Application 1",
            "description": "Sample application 1",
            "iconUrl": ""
        },
        {
            "id": "app2",
            "name": "Application 2", 
            "description": "Sample application 2",
            "iconUrl": ""
        }
    ]"#;
    
    create_result(true, None, Some(apps_json.to_string()))
}

// Launch an application
#[no_mangle]
pub extern "C" fn rcp_launch_app(app_id: *const c_char) -> RcpResult {
    let app_id_str = match from_c_string(app_id) {
        Ok(s) => s,
        Err(e) => return create_result(false, Some(e), None),
    };
    
    // Mock implementation
    create_result(true, None, None)
}

// Log out the current user
#[no_mangle]
pub extern "C" fn rcp_logout() -> RcpResult {
    // Mock implementation
    create_result(true, None, None)
}
EOL
fi

# Step 2: Fix paths in scripts
echo "Fixing paths in scripts..."

# Make scripts executable
chmod +x "$SCRIPT_DIR/build_rust_bridge.sh"
chmod +x "$SCRIPT_DIR/copy_native_libs.sh"
chmod +x "$SCRIPT_DIR/migrate.sh"
chmod +x "$SCRIPT_DIR/fix_compilation_issues.sh"

# Step 3: Update workspace Cargo.toml to include the rust_bridge
echo "Updating workspace Cargo.toml..."
WORKSPACE_CARGO_TOML="$(dirname "$SCRIPT_DIR")/Cargo.toml"

if grep -q "flutter_rcp_client/rust" "$WORKSPACE_CARGO_TOML"; then
    # Replace the old rust directory with rust_bridge
    sed -i.bak 's|"flutter_rcp_client/rust"|"flutter_rcp_client/rust_bridge"|g' "$WORKSPACE_CARGO_TOML"
    rm -f "${WORKSPACE_CARGO_TOML}.bak"
    echo "✅ Updated workspace Cargo.toml"
fi

# Step 4: Run the fix_compilation_issues script
echo "Running fix_compilation_issues.sh..."
"$SCRIPT_DIR/fix_compilation_issues.sh"

echo "✅ Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Try building the Rust bridge: ./build_rust_bridge.sh"
echo "2. Copy the libraries: ./copy_native_libs.sh"
echo "3. Build and run the Flutter app: flutter run"
echo ""
echo "Documentation files to review:"
echo "- FFI_BRIDGE_DOCS.md - Detailed documentation on the FFI bridge architecture"
echo "- NATIVE_LIBRARY_SETUP.md - Instructions for setting up native libraries"
echo "- INTEGRATION.md - Overview of the dependency-free integration approach"
