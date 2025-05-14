# Understanding cbindgen.toml Configuration

This document provides a detailed explanation of the `cbindgen.toml` configuration file used in the Flutter RCP client Rust bridge.

## Introduction

The `cbindgen.toml` file controls how Rust code is exposed to C/C++ (and by extension, to Dart through FFI). It's used by the `cbindgen` tool during the build process to generate appropriate C header files.

## Configuration Details

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

- **How it works**: When Rust code uses platform-specific features with `#[cfg(target_os = "ios")]`, the generated C header will use `#ifdef TARGET_OS_IOS` to maintain platform consistency.

- **Why it's important**: This ensures that platform-specific code in both Rust and C/C++ (and by extension, Dart) remains aligned and only compiles for the appropriate targets.

### Export Section

```toml
[export]
prefix = "RCP"
include = ["RcpResult", "RcpError", "AppInfo", "User"]
```

**Purpose**: Controls which Rust types are exported to C and how they're prefixed.

- **prefix**: Adds "RCP" prefix to all exported types that don't have specific renaming rules
  
- **include**: Explicitly lists which types should be exported
  - Only these types will appear in the C header
  - Types not listed will not be accessible from Dart/C

- **Why this matters**: It creates a clean API boundary, exposing only what's necessary and maintaining a consistent naming convention.

### Export.Rename Section

```toml
[export.rename]
"RcpResult" = "RcpResult"
"RcpError" = "RcpError"
```

**Purpose**: Provides explicit control over how specific Rust types are named in the C API.

- **Format**: `"RustTypeName" = "CTypeName"`

- **Example above**: Keeps the names the same but makes the mapping explicit

- **Usage scenarios**:
  - When you want a different name in C than in Rust
  - When you need to avoid name conflicts
  - When following specific naming conventions

### Enum Section

```toml
[enum]
prefix_with_name = true
rename_variants = "ScreamingSnakeCase"
```

**Purpose**: Controls how Rust enums are converted to C enums.

- **prefix_with_name**: When `true`, enum variants are prefixed with the enum name
  - Example: `enum Error { NotFound }` becomes `ERROR_NOT_FOUND` in C

- **rename_variants**: Controls casing of enum variants
  - `"ScreamingSnakeCase"` converts to ALL_CAPS_WITH_UNDERSCORES
  - This follows common C convention for enum constants

## How This Affects the FFI Bridge

The configuration directly impacts how Rust and Dart/Flutter communicate:

1. **Type Mapping**: Determines how Rust types appear to Dart code
2. **Memory Management**: Affects how data is passed between languages
3. **Platform Detection**: Controls conditional compilation across platforms
4. **API Surface**: Limits which functions and types are exposed

## Best Practices

1. **Limit exposed API surface**: Only include types and functions that are needed
2. **Use consistent naming**: Follow C conventions in the exported API
3. **Document edge cases**: Note any platform-specific behaviors
4. **Test thoroughly**: Verify the FFI bridge works correctly on all target platforms

## Related Files

- `build.rs`: Uses cbindgen to generate the headers during build
- `src/lib.rs`: Contains the Rust functions exposed via FFI
- `lib/services/rcp_bridge.dart`: The Dart side of the FFI bridge

## Configuration Parameters Reference

Here are other parameters you might see in cbindgen configurations:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `language.cpp` | Generate C++ instead of C | `cpp = true` |
| `parse.parse_deps` | Include dependencies | `parse_deps = true` |
| `fn.rename_args` | Rename function parameters | `rename_args = "camelCase"` |
| `struct.derive_eq` | Add == operator to structs | `derive_eq = true` |
| `documentation.style` | Doc comment style | `style = "doxy"` |

## Links to Learn More

- [cbindgen Documentation](https://github.com/eqrion/cbindgen/blob/master/docs.md)
- [Dart FFI Documentation](https://dart.dev/guides/libraries/c-interop)
- [Rust FFI Guide](https://doc.rust-lang.org/nomicon/ffi.html)
