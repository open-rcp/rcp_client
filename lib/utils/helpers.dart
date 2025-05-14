import 'package:flutter/material.dart';
import 'constants.dart';

/// Extension methods and utility functions
extension StringExtensions on String? {
  /// Check if a string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Check if a string is a valid hostname or IP address
  bool get isValidHostnameOrIP {
    if (isNullOrEmpty) return false;
    return AppConstants.hostnameRegex.hasMatch(this!) || 
           AppConstants.ipAddressRegex.hasMatch(this!);
  }
}

extension IntExtensions on int? {
  /// Check if an integer is a valid port number
  bool get isValidPort {
    if (this == null) return false;
    return this! >= AppConstants.minPort && this! <= AppConstants.maxPort;
  }
}

class FormValidators {
  /// Validate a required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} is required';
    }
    return null;
  }
  
  /// Validate a hostname or IP address
  static String? validateHostname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hostname is required';
    }
    if (!value.isValidHostnameOrIP) {
      return 'Enter a valid hostname or IP address';
    }
    return null;
  }
  
  /// Validate a port number
  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Port is required';
    }
    
    final port = int.tryParse(value);
    if (port == null) {
      return 'Port must be a number';
    }
    
    if (!port.isValidPort) {
      return 'Port must be between ${AppConstants.minPort} and ${AppConstants.maxPort}';
    }
    
    return null;
  }
}

/// Helper class for showing status messages
class MessageUtils {
  /// Show a snackbar message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }
  
  /// Show a loading dialog
  static Future<void> showLoadingDialog(BuildContext context, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }
}
