# cbindgen.toml Configuration Documentation

This document explains the configuration options in the `cbindgen.toml` file used for the Flutter RCP client Rust bridge.

## Overview

[cbindgen](https://github.com/eqrion/cbindgen) is a tool that generates C/C++ bindings for Rust code. The `cbindgen.toml` file configures how Rust types and functions are exposed to C/C++ (and by extension, to Dart through FFI).

## File Location

```
flutter_rcp_client/rust_bridge/cbindgen.toml
```

## Configuration Sections

### Defines Section

```toml
[defines]
"target_os = ios" = "TARGET_OS_IOS"
"target_os = macos" = "TARGET_OS_MACOS"
"target_os = android" = "TARGET_OS_ANDROID"
"target_os = windows" = "TARGET_OS_WINDOWS"
"target_os = linux" = "TARGET_OS_LINUX"
```

**Purpose**: This section maps Rust's conditional compilation attributes to C preprocessor defines.

- When Rust code uses `#[cfg(target_os = "ios")]`, the generated C header will use `#ifdef TARGET_OS_IOS`
- This allows platform-specific code in both languages to be aligned

### Export Section

```toml
[export]
prefix = "RCP"
include = ["RcpResult", "RcpError", "AppInfo", "User"]
```

**Purpose**: Controls which Rust types are exported to C and how they're prefixed.

- `prefix = "RCP"`: Adds "RCP" prefix to all exported types (except those explicitly renamed)
- `include`: Explicit list of types that should be exported to C
  - Only these types will be included in the generated bindings
  - Types not in this list will be excluded from the C API

### Export.Rename Section

```toml
[export.rename]
"RcpResult" = "RcpResult"
"RcpError" = "RcpError"
```

**Purpose**: Explicitly renames specific Rust types in the generated C bindings.

- Keys are the original Rust type names
- Values are the desired C type names
- In this case, we're keeping the names the same but being explicit about it

### Enum Section

```toml
[enum]
prefix_with_name = true
rename_variants = "ScreamingSnakeCase"
```

**Purpose**: Configures how Rust enums are converted to C enums.

- `prefix_with_name = true`: Enum variants will be prefixed with the enum name
  - Example: `enum Error { NotFound }` becomes `ERROR_NOT_FOUND` in C
- `rename_variants = "ScreamingSnakeCase"`: Formats enum variant names in ALL_CAPS_WITH_UNDERSCORES
  - This follows common C convention for enum constants

## Additional Configuration Options

cbindgen supports many more options not currently used in our configuration:

### Language Settings

```toml
# Not currently used, but available:
[parse]
parse_deps = false
include = []
exclude = []

[language]
cpp = false  # Set to true for C++ output
```

### Documentation

```toml
# Not currently used, but available:
[export.documentation]
include = true  # Include Rust doc comments in C output
style = "auto"  # How to format doc comments
```

### Type Configuration

```toml
# Not currently used, but available:
[struct]
rename_fields = "CamelCase"  # Override field naming convention

[fn]
rename_args = "camelCase"    # Override function parameter naming
```

## Best Practices

1. **Only export necessary types**: Keep the `include` list minimal
2. **Use consistent naming conventions**: Follow C naming conventions in generated code
3. **Test bindings**: Ensure the generated headers work correctly with C/C++ code
4. **Update this file**: When adding new types to be exported, add them to the `include` list

## Related Files

- `rust_bridge/build.rs`: Calls cbindgen to generate headers during build
- `rust_bridge/src/lib.rs`: Contains the exported Rust API
