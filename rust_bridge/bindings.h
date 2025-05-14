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

struct RCPUser {
  char *username;
  char *display_name;
  char *email;
};

struct RCPAppInfo {
  char *id;
  char *name;
  char *description;
  char *icon_url;
};

extern "C" {

void rcp_free_result(RCPRcpResult result);

void rcp_free_user(RCPUser user);

void rcp_free_app_info(RCPAppInfo app);

RCPRcpResult rcp_init(const char *host, int32_t port);

RCPRcpResult rcp_authenticate(const char *username, const char *password);

RCPRcpResult rcp_get_available_apps();

RCPRcpResult rcp_launch_app(const char *app_id);

RCPRcpResult rcp_logout();

} // extern "C"
