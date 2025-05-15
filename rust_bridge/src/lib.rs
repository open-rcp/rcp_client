/*!
Bridge module for FFI between Flutter RCP client and Rust

This module provides FFI functions for the Flutter RCP client to interact with
the Rust-based RCP client libraries.
*/

use std::ffi::{c_char, CStr, CString};
use std::ptr;

// Struct definitions for FFI

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

// Helper functions

fn create_success_result(data: &str) -> RcpResult {
    let c_data = match CString::new(data) {
        Ok(s) => s.into_raw(),
        Err(_) => ptr::null_mut(),
    };

    RcpResult {
        success: true,
        error_message: ptr::null_mut(),
        data: c_data,
    }
}

fn create_error_result(error: &str) -> RcpResult {
    let c_error = match CString::new(error) {
        Ok(s) => s.into_raw(),
        Err(_) => ptr::null_mut(),
    };

    RcpResult {
        success: false,
        error_message: c_error,
        data: ptr::null_mut(),
    }
}

// FFI functions

/// # Safety
///
/// This function expects valid null-terminated C string pointers.
#[no_mangle]
pub unsafe extern "C" fn rcp_connect_to_server(
    host: *const c_char,
    port: i32,
    timeout_ms: i32,
) -> RcpResult {
    // Validate inputs
    if host.is_null() {
        return create_error_result("Host cannot be null");
    }

    // Convert C string to Rust string
    let host_str = match CStr::from_ptr(host).to_str() {
        Ok(s) => s,
        Err(_) => return create_error_result("Invalid UTF-8 in host string"),
    };

    // TODO: Implement actual connection logic using RCP libraries
    println!(
        "Connecting to {}:{} (timeout: {}ms)",
        host_str, port, timeout_ms
    );

    // For now, simulate a successful connection
    create_success_result("{\"connectionId\":\"mock-123\",\"serverVersion\":\"1.0.0\"}")
}

/// # Safety
///
/// This function expects valid null-terminated C string pointers.
#[no_mangle]
pub unsafe extern "C" fn rcp_authenticate(
    connection_id: *const c_char,
    username: *const c_char,
    password: *const c_char,
) -> RcpResult {
    // Validate inputs
    if connection_id.is_null() || username.is_null() || password.is_null() {
        return create_error_result("Connection ID, username, and password cannot be null");
    }

    // Convert C strings to Rust strings
    let connection_id_str = match CStr::from_ptr(connection_id).to_str() {
        Ok(s) => s,
        Err(_) => return create_error_result("Invalid UTF-8 in connection ID"),
    };

    let username_str = match CStr::from_ptr(username).to_str() {
        Ok(s) => s,
        Err(_) => return create_error_result("Invalid UTF-8 in username"),
    };

    // Password is validated but not printed for security
    let _password_str = match CStr::from_ptr(password).to_str() {
        Ok(_) => "********",
        Err(_) => return create_error_result("Invalid UTF-8 in password"),
    };

    // TODO: Implement actual authentication logic
    println!(
        "Authenticating user {} on connection {}",
        username_str, connection_id_str
    );

    // Simulate successful authentication
    create_success_result(
        "{\"sessionId\":\"sess-456\",\"userId\":\"user-789\",\"tokenExpiry\":3600}",
    )
}

/// # Safety
///
/// This function expects a valid null-terminated C string pointer.
#[no_mangle]
pub unsafe extern "C" fn rcp_get_available_apps(session_id: *const c_char) -> RcpResult {
    // Validate input
    if session_id.is_null() {
        return create_error_result("Session ID cannot be null");
    }

    // Convert C string to Rust string
    let session_id_str = match CStr::from_ptr(session_id).to_str() {
        Ok(s) => s,
        Err(_) => return create_error_result("Invalid UTF-8 in session ID"),
    };

    // TODO: Implement actual app listing logic
    println!("Getting available apps for session {}", session_id_str);

    // Simulate a list of apps in JSON format
    let apps_json = r#"[
      {"id": "app1", "name": "Terminal", "description": "Command-line interface", "icon_url": "terminal.png"},
      {"id": "app2", "name": "Browser", "description": "Web browser", "icon_url": "browser.png"},
      {"id": "app3", "name": "Editor", "description": "Text editor", "icon_url": "editor.png"}
    ]"#;

    create_success_result(apps_json)
}

/// # Safety
///
/// This function expects valid null-terminated C string pointers.
#[no_mangle]
pub unsafe extern "C" fn rcp_launch_app(
    session_id: *const c_char,
    app_id: *const c_char,
) -> RcpResult {
    // Validate inputs
    if session_id.is_null() || app_id.is_null() {
        return create_error_result("Session ID and app ID cannot be null");
    }

    // Convert C strings to Rust strings
    let session_id_str = match CStr::from_ptr(session_id).to_str() {
        Ok(s) => s,
        Err(_) => return create_error_result("Invalid UTF-8 in session ID"),
    };

    let app_id_str = match CStr::from_ptr(app_id).to_str() {
        Ok(s) => s,
        Err(_) => return create_error_result("Invalid UTF-8 in app ID"),
    };

    // TODO: Implement actual app launching logic
    println!(
        "Launching app {} for session {}",
        app_id_str, session_id_str
    );

    // Simulate successful app launch
    create_success_result(
        "{\"launchId\":\"launch-101\",\"displayUrl\":\"ws://server/display/101\"}",
    )
}

/// # Safety
///
/// This function expects a valid pointer to an RcpResult.
/// It should be called to free memory allocated by previous FFI calls.
#[no_mangle]
pub unsafe extern "C" fn rcp_free_result(result: *mut RcpResult) {
    if result.is_null() {
        return;
    }

    let result_ref = &mut *result;

    // Free the error message if it exists
    if !result_ref.error_message.is_null() {
        let _ = CString::from_raw(result_ref.error_message);
        result_ref.error_message = ptr::null_mut();
    }

    // Free the data if it exists
    if !result_ref.data.is_null() {
        let _ = CString::from_raw(result_ref.data);
        result_ref.data = ptr::null_mut();
    }
}
