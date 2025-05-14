# Migration Plan: Dependency-Free Flutter RCP Client

This document outlines the steps to transition the Flutter RCP client to be dependency-free from other Rust projects except through the dedicated bridge.

## Steps to Migrate

### 1. Create and Update Files (Already Completed)

✅ Create dedicated `rust_bridge` crate
✅ Create Rust FFI interface in `lib.rs`
✅ Update main workspace Cargo.toml
✅ Create Dart FFI binding code
✅ Create build and copy scripts
✅ Create new implementation versions of services

### 2. Testing the New Architecture

- [ ] Build the Rust bridge for your primary development platform:

```bash
cd flutter_rcp_client
./build_rust_bridge.sh
```

- [ ] Ensure libraries are properly copied to platform locations:

```bash
./copy_native_libs.sh
```

- [ ] Test basic connectivity with the server using the new bridge

### 3. File Replacement (To Be Completed)

- [ ] Replace `lib/services/rcp_service.dart` with `rcp_service_new.dart`
- [ ] Replace `lib/services/auth_service.dart` with `auth_service_new.dart`
- [ ] Replace `lib/main.dart` with `main_new.dart`
- [ ] Remove any old utility files no longer needed

### 4. Code Cleanup

- [ ] Remove any old Rust integration code (e.g., previous Flutter FFI implementation)
- [ ] Verify all imports are updated to reference new file names
- [ ] Remove any temporary backup files

### 5. Testing

- [ ] Test app on all target platforms:
  - [ ] macOS
  - [ ] iOS (simulator and device)
  - [ ] Android (emulator and device)
  - [ ] Windows
  - [ ] Linux

- [ ] Verify the following functionality:
  - [ ] Server connection
  - [ ] Authentication
  - [ ] App listing
  - [ ] App launching
  - [ ] Streaming
  - [ ] Logout

### 6. Documentation

- [ ] Update main README.md to reference new architecture
- [ ] Review and update comments in code
- [ ] Document any platform-specific considerations

## Rollback Plan

If issues arise during migration:

1. Revert the file changes made during migration
2. Restore any deleted files
3. Remove the new bridge implementation if necessary
4. Return to the previous integration method

## Timeline

- Day 1: Complete steps 1-2 (Setup and testing bridge)
- Day 2: Complete steps 3-4 (File replacement and cleanup)
- Day 3: Complete steps 5-6 (Testing and documentation)

## Notes

- The new architecture reduces coupling between projects
- Future updates to the RCP core will require fewer changes in the Flutter client
- The bridge serves as a well-defined interface boundary
