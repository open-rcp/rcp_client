import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Function type definitions for FFI bridge to Rust
typedef ConnectToServerNative = Int32 Function(Pointer<Utf8>, Int32);
typedef ConnectToServerDart = int Function(Pointer<Utf8>, int);

typedef AuthenticateUserNative = Int32 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef AuthenticateUserDart = int Function(Pointer<Utf8>, Pointer<Utf8>);

typedef GetAvailableAppsNative =
    Pointer<Pointer<Utf8>> Function(Pointer<Int32>);
typedef GetAvailableAppsDart = Pointer<Pointer<Utf8>> Function(Pointer<Int32>);

typedef LaunchAppNative = Int32 Function(Pointer<Utf8>);
typedef LaunchAppDart = int Function(Pointer<Utf8>);

/// FFI result codes
class FfiResultCodes {
  static const int success = 0;
  static const int errorNullPointer = -1;
  static const int errorInvalidUtf8 = -2;
  static const int errorConnection = -3;
  static const int errorAuthentication = -4;
  static const int errorLaunch = -5;

  /// Convert FFI result code to a human-readable message
  static String getMessage(int code) {
    switch (code) {
      case success:
        return 'Success';
      case errorNullPointer:
        return 'Null pointer error';
      case errorInvalidUtf8:
        return 'Invalid UTF-8 in string parameter';
      case errorConnection:
        return 'Connection error';
      case errorAuthentication:
        return 'Authentication error';
      case errorLaunch:
        return 'Application launch error';
      default:
        return 'Unknown error: $code';
    }
  }
}
