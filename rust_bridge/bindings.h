#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

struct RCPRcpResult {
  bool success;
  char *error_message;
  char *data;
};

struct RCPAppInfo {
  char *id;
  char *name;
  char *description;
  char *icon_url;
};

struct RCPUser {
  char *username;
  char *display_name;
  char *email;
};

extern "C" {

/// # Safety
///
/// This function expects valid null-terminated C string pointers.
RCPRcpResult rcp_connect_to_server(const char *host, int32_t port, int32_t timeout_ms);

/// # Safety
///
/// This function expects valid null-terminated C string pointers.
RCPRcpResult rcp_authenticate(const char *connection_id,
                              const char *username,
                              const char *password);

/// # Safety
///
/// This function expects a valid null-terminated C string pointer.
RCPRcpResult rcp_get_available_apps(const char *session_id);

/// # Safety
///
/// This function expects valid null-terminated C string pointers.
RCPRcpResult rcp_launch_app(const char *session_id, const char *app_id);

/// # Safety
///
/// This function expects a valid pointer to an RcpResult.
/// It should be called to free memory allocated by previous FFI calls.
void rcp_free_result(RCPRcpResult *result);

} // extern "C"
