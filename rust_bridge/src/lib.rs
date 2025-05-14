/*!
Bridge module for FFI between Flutter RCP client and Rust

This module provides FFI functions for the Flutter RCP client to interact with
the Rust-based RCP client libraries.
*/

use std::ffi::{c_char, CStr, CString};
use std::ptr;

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
    
    // Create a simple runtime for async operations
    match Runtime::new() {
        Ok(rt) => {
            let config = ClientConfig {
                server_host: host_str,
                server_port: port as u16,
                // Add other config options as needed
                ..Default::default()
            };
            
            match rt.block_on(async {
                Client::new(config).await
            }) {
                Ok(_client) => {
                    // Store client in a global state or return a client handle
                    // This is simplified and should use proper state management
                    create_result(true, None, None)
                },
                Err(e) => create_result(false, Some(format!("Failed to initialize client: {}", e)), None),
            }
        },
        Err(e) => create_result(false, Some(format!("Failed to create runtime: {}", e)), None),
    }
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
    
    // Implementation would authenticate with the RCP server
    // This is a simplified example that would need proper implementation
    
    // Mock successful authentication for demonstration
    let user_json = format!(r#"{{
        "username": "{}",
        "displayName": "Test User",
        "email": "{}@example.com"
    }}"#, username_str, username_str);
    
    create_result(true, None, Some(user_json))
}

// Get available applications
#[no_mangle]
pub extern "C" fn rcp_get_available_apps() -> RcpResult {
    // Implementation would fetch apps from RCP server
    // This is a simplified example
    
    // Mock apps data for demonstration
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
    
    // Implementation would launch the app via RCP server
    // This is a simplified example
    
    create_result(true, None, None)
}

// Log out the current user
#[no_mangle]
pub extern "C" fn rcp_logout() -> RcpResult {
    // Implementation would log out via RCP server
    // This is a simplified example
    
    create_result(true, None, None)
}
