import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_info.dart';
import '../models/app_state.dart';
import '../widgets/copyable_error_message.dart';

/// Screen for streaming and interacting with a remote application
class StreamingScreen extends StatefulWidget {
  final AppInfo appInfo;

  const StreamingScreen({super.key, required this.appInfo});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  // Service is accessed through Provider instead
  // final _rcpService = RcpService();

  bool _isConnected = true;
  bool _isFullscreen = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // In a real implementation, we would set up event listeners for stream updates
  }

  @override
  void dispose() {
    // In a real implementation, we would clean up resources and notify the server
    super.dispose();
  }

  /// Close the application and return to the app launcher
  void _closeApplication() {
    // In a real implementation, we would send a close command to the server

    // Update app state
    final appState = context.read<AppState>();
    appState.setActiveApp(null);

    // Return to launcher
    Navigator.of(context).pop();
  }

  /// Toggle fullscreen mode
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  /// Reconnect to the application if connection is lost
  Future<void> _reconnect() async {
    setState(() => _errorMessage = null);

    try {
      // In a real implementation, we would attempt to reconnect to the stream
      setState(() => _isConnected = true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to reconnect: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isFullscreen
              ? null
              : AppBar(
                title: Text(widget.appInfo.name),
                actions: [
                  // Fullscreen toggle
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: _toggleFullscreen,
                    tooltip: 'Toggle Fullscreen',
                  ),
                  // Close application
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeApplication,
                    tooltip: 'Close Application',
                  ),
                ],
              ),
      body: _buildStreamingContent(),
    );
  }

  Widget _buildStreamingContent() {
    if (!_isConnected) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Connection Lost',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CopyableErrorMessage(
                    message: _errorMessage!,
                    title: 'Connection Error',
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _reconnect,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reconnect'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _closeApplication,
                    child: const Text('Close Application'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Placeholder for the actual streaming content
    // In a real implementation, this would be replaced with a proper video stream widget
    return GestureDetector(
      onTap: _isFullscreen ? _toggleFullscreen : null,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Placeholder for the streaming content
          Center(
            child: SingleChildScrollView(
              // Added ScrollView to handle overflow
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    MainAxisSize.min, // Added to reduce size to minimum needed
                children: [
                  Image.network(
                    'https://via.placeholder.com/640x480?text=${widget.appInfo.name}',
                    width: 640,
                    height: 480,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 640,
                        height: 480,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Text(
                          widget.appInfo.name,
                          style: const TextStyle(fontSize: 24),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Application Streaming Placeholder',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is where the actual application stream would be displayed.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          // Fullscreen toggle button (in fullscreen mode)
          if (_isFullscreen)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _toggleFullscreen,
                child: const Icon(Icons.fullscreen_exit),
              ),
            ),
        ],
      ),
    );
  }
}
