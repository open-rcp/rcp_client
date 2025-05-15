import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget for displaying error messages that can be copied to clipboard
class CopyableErrorMessage extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional title for the error message
  final String title;

  /// Optional additional padding
  final EdgeInsetsGeometry padding;

  /// Optional margin
  final EdgeInsetsGeometry margin;

  /// Callback when error is copied
  final VoidCallback? onCopied;

  /// Create a copyable error message widget
  const CopyableErrorMessage({
    super.key,
    required this.message,
    this.title = 'Error',
    this.padding = const EdgeInsets.all(12),
    this.margin = EdgeInsets.zero,
    this.onCopied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withAlpha(26), // Using withAlpha instead of withOpacity (0.1 * 255 ≈ 26)
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withAlpha(77), // Using withAlpha instead of withOpacity (0.3 * 255 ≈ 77)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.content_copy, size: 16),
                tooltip: 'Copy error message',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error message copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  onCopied?.call();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }
}
